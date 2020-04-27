### NameServer架构设计

![RocketMQ物理部署图](.\pic\RocketMQ物理部署图.png)

Broker消息服务器在启动时向所有NameServer注册，消息生产者（Producer）在发送消息之前**先从NameServer获取Broker服务器地址列表**，然后根据**负载算法**从列表中选择一台消息服务器进行消息发送。NameServer与每台Broker服务器保持长连接，**并间隔30s检测Broker是否存活**，如果检测到Broker宕机，则从路由注册表中将其移除。

NameServer本身的高可用可通过部署多台NameServer服务器来实现，**但彼此之间互不通信**，也就是NameServer服务器之间在某一时刻的数据并不会完全相同，但这对消息发送不会造成任何影响，这也是RocketMQ NameServer设计的一个亮点，RocketMQ NameServer设计追求简单高效。

## NameServer启动流程

Step1：首先来解析配置文件，需要填充NameServerConfig、NettyServerConfig属性值。

Step2：根据启动属性创建NamesrvController实例，并初始化该实例，NameServerController实例为NameServer核心控制器。

加载KV配置，创建NettyServer网络处理对象，然后开启两个定时任务，在RocketMQ中此类定时任务统称为心跳检测。

□ 定时任务1:NameServer每隔10s扫描一次Broker，移除处于不激活状态的Broker。

□ 定时任务2:nameServer每隔10分钟打印一次KV配置。

Step3：注册JVM钩子函数并启动服务器，以便监听Broker、消息生产者的网络请求。

### NameServer路由注册、故障剔除

NameServer需要**存储路由的基础信息**，还要能够**管理Broker节点**，包括**路由注册、路由删除**等功能。

#### 路由元信息

□ topicQueueTable:**Topic消息队列路由信息**，消息发送时根据路由表进行负载均衡。

□ brokerAddrTable:Broker基础信息，包含brokerName、所属集群名称、主备Broker地址。

□ clusterAddrTable:Broker集群信息，存储集群中所有Broker名称。

□ brokerLiveTable:Broker状态信息。NameServer每次收到心跳包时会替换该信息。

□ filterServerTable:Broker上的FilterServer列表，用于类模式消息过滤、。

RocketMQ基于**订阅发布机制**，一个Topic拥有多个消息队列，一个Broker为**每一主题默认创建4个读队列4个写队列**。多个Broker组成一个集群，BrokerName由相同的多台Broker组成Master-Slave架构，**brokerId为0代表Master，大于0表示Slave**。BrokerLiveInfo中的lastUpdateTimestamp存储上次收到Broker心跳包的时间。

Broker启动时向集群中所有的NameServer发送心跳语句，**每隔30s向集群中所有NameServer发送心跳包**，NameServer收到Broker心跳包时会**更新brokerLiveTable缓存中BrokerLiveInfo的lastUpdateTimestamp**，然后**Name Server每隔10s扫描brokerLiveTabl**e，如果连续120s没有收到心跳包，NameServer将移除该Broker的路由信息同时关闭Socket连接。

RocketMQ网络传输基于Netty

#### 路由注册

- Broker发送心跳包
- NameServer处理心跳包
  - Step1：路由注册需要加写锁，防止并发修改RouteInfoManager中的路由表。
  - Step2：维护BrokerData信息，首先从brokerAddrTable根据BrokerName尝试获取Broker信息，如果不存在，则新建BrokerData并放入到brokerAddrTable, registerFirst设置为true；如果存在，直接替换原先的，registerFirst设置为false，表示非第一次注册。
  - Step3：如果Broker为Master，并且Broker Topic配置信息发生变化或者是初次注册，则需要创建或更新Topic路由元数据，填充topicQueueTable，其实就是为默认主题自动注册路由信息，其中包含MixAll.DEFAULT_TOPIC的路由信息。当消息生产者发送主题时，如果该主题未创建并且BrokerConfig的autoCreateTopicEnable为true时，将返回MixAll. DEFAULT_TOPIC的路由信息。
  - Step4：更新BrokerLiveInfo，存活Broker信息表，BrokeLiveInfo是执行路由删除的重要依据。
  - Step5：注册Broker的过滤器Server地址列表，一个Broker上会关联多个FilterServer消息过滤服务器，此部分内容将在第6章详细介绍；如果此Broker为从节点，则需要查找该Broker的Master的节点信息，并更新对应的masterAddr属性。

设计亮点：

NameServe与Broker保持长连接，Broker状态存储在brokerLiveTable中，NameServer每收到一个心跳包，将更新brokerLiveTable中关于Broker的状态信息以及路由表（topicQueueTable、brokerAddrTable、brokerLiveTable、filterServerTable）。更新上述路由表（HashTable）使用了锁粒度较少的读写锁，允许多个消息发送者（Producer）并发读，保证消息发送时的高并发。但同一时刻NameServer只处理一个Broker心跳包，多个心跳包请求串行执行。这也是读写锁经典使用场景，更多关于读写锁的信息，可以参考笔者的博文：http://blog.csdn.net/prestigeding/article/details/53286756

#### 路由删除

Broker每隔30s向NameServer发送一个心跳包，心跳包中包含BrokerId、Broker地址、Broker名称、Broker所属集群名称、Broker关联的FilterServer列表。

Name Server会每隔10s扫描brokerLiveTable状态表，如果BrokerLive的lastUpdateTimestamp的时间戳距当前时间超过120s，则认为Broker失效，移除该Broker，关闭与Broker连接，并同时更新topicQueueTable、brokerAddrTable、brokerLiveTable、filterServerTable。

RocktMQ有两个触发点来触发路由删除：

- NameServer定时扫描brokerLiveTable检测上次心跳包与当前系统时间的时间差，如果时间戳大于120s，则需要移除该Broker信息。
- Broker在正常被关闭的情况下，会执行unregisterBroker指令。

Step1：申请写锁，根据brokerAddress从brokerLiveTable、filterServerTable移除。

Step2：维护brokerAddrTable。遍历从HashMap<String/* brokerName */,BrokerData>brokerAddrTable，从BrokerData的HashMap<Long/* brokerId */, String/*broker address */>brokerAddrs中，找到具体的Broker，从BrokerData中移除，如果移除后在BrokerData中不再包含其他Broker，则在brokerAddrTable中移除该brokerName对应的条目。

Step3：根据BrokerName，从clusterAddrTable中找到Broker并从集群中移除。如果移除后，集群中不包含任何Broker，则将该集群从clusterAddrTable中移除。

Step4：根据brokerName，遍历所有主题的队列，如果队列中包含了当前Broker的队列，则移除，如果topic只包含待移除Broker的队列的话，从路由表中删除该topic，如代码清单2-21所示。

Step5：释放锁，完成路由删除。

####  路由发现

RocketMQ路由发现是**非实时的**，当Topic路由出现变化后，**NameServer不主动推送给客户端，而是由客户端定时拉取主题最新的路由**。

