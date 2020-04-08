### NameServer架构设计

![RocketMQ物理部署图](.\pic\RocketMQ物理部署图.png)

Broker消息服务器在启动时向所有NameServer注册，消息生产者（Producer）在发送消息之前**先从NameServer获取Broker服务器地址列表**，然后根据**负载算法**从列表中选择一台消息服务器进行消息发送。NameServer与每台Broker服务器保持长连接，**并间隔30s检测Broker是否存活**，如果检测到Broker宕机，则从路由注册表中将其移除。

NameServer本身的高可用可通过部署多台NameServer服务器来实现，**但彼此之间互不通信**，也就是NameServer服务器之间在某一时刻的数据并不会完全相同，但这对消息发送不会造成任何影响，这也是RocketMQ NameServer设计的一个亮点，RocketMQ NameServer设计追求简单高效。



### NameServer路由注册、故障剔除

NameServer需要**存储路由的基础信息**，还要能够**管理Broker节点**，包括**路由注册、路由删除**等功能。

RocketMQ基于**订阅发布机制**，一个Topic拥有多个消息队列，一个Broker为**每一主题默认创建4个读队列4个写队列**。多个Broker组成一个集群，BrokerName由相同的多台Broker组成Master-Slave架构，**brokerId为0代表Master，大于0表示Slave**。BrokerLiveInfo中的lastUpdateTimestamp存储上次收到Broker心跳包的时间。

Broker启动时向集群中所有的NameServer发送心跳语句，**每隔30s向集群中所有NameServer发送心跳包**，NameServer收到Broker心跳包时会**更新brokerLiveTable缓存中BrokerLiveInfo的lastUpdateTimestamp**，然后Name Server每隔10s扫描brokerLiveTable，如果连续120s没有收到心跳包，NameServer将移除该Broker的路由信息同时关闭Socket连接。

RocketMQ网络传输基于Netty

设计亮点：

NameServe与Broker保持长连接，Broker状态存储在brokerLiveTable中，NameServer每收到一个心跳包，将更新brokerLiveTable中关于Broker的状态信息以及路由表（topicQueueTable、brokerAddrTable、brokerLiveTable、filterServerTable）。更新上述路由表（HashTable）使用了锁粒度较少的读写锁，允许多个消息发送者（Producer）并发读，保证消息发送时的高并发。但同一时刻NameServer只处理一个Broker心跳包，多个心跳包请求串行执行。这也是读写锁经典使用场景，更多关于读写锁的信息，可以参考笔者的博文：http://blog.csdn.net/prestigeding/article/details/53286756

#### 路由删除

Broker每隔30s向NameServer发送一个心跳包，心跳包中包含BrokerId、Broker地址、Broker名称、Broker所属集群名称、Broker关联的FilterServer列表。

Name Server会每隔10s扫描brokerLiveTable状态表，如果BrokerLive的lastUpdateTimestamp的时间戳距当前时间超过120s，则认为Broker失效，移除该Broker，关闭与Broker连接，并同时更新topicQueueTable、brokerAddrTable、brokerLiveTable、filterServerTable。

RocktMQ有两个触发点来触发路由删除：

- NameServer定时扫描brokerLiveTable检测上次心跳包与当前系统时间的时间差，如果时间戳大于120s，则需要移除该Broker信息。
- Broker在正常被关闭的情况下，会执行unregisterBroker指令。

####  路由发现

RocketMQ路由发现是非实时的，当Topic路由出现变化后，NameServer不主动推送给客户端，而是由客户端定时拉取主题最新的路由。

