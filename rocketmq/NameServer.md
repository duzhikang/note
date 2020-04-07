### NameServer架构设计

![RocketMQ物理部署图](.\pic\RocketMQ物理部署图.png)

Broker消息服务器在启动时向所有NameServer注册，消息生产者（Producer）在发送消息之前**先从NameServer获取Broker服务器地址列表**，然后根据**负载算法**从列表中选择一台消息服务器进行消息发送。NameServer与每台Broker服务器保持长连接，**并间隔30s检测Broker是否存活**，如果检测到Broker宕机，则从路由注册表中将其移除。

NameServer本身的高可用可通过部署多台NameServer服务器来实现，**但彼此之间互不通信**，也就是NameServer服务器之间在某一时刻的数据并不会完全相同，但这对消息发送不会造成任何影响，这也是RocketMQ NameServer设计的一个亮点，RocketMQ NameServer设计追求简单高效。