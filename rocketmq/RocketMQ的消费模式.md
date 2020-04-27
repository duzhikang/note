### RocketMQ的消费模式

consumer 订阅了 broker 上的某个 topic，当 producer 发布消息到 broker 上的该 topic 时，consumer 就能收到该条消息。

消费同一类消息的多个 consumer 实例组成一个消费者组，也可以称为一个 consumer 集群，这些 consumer 实例使用同一个 group name。**除了使用同一个 group name，订阅的 tag 也必须是一样的，只有符合这两个条件的 consumer 实例才能组成 consumer 集群。**

## 集群消费

当 consumer 使用集群消费时，每条消息只会被 consumer 集群内的任意一个 consumer 实例消费一次。举个例子，当一个 consumer 集群内有 3 个consumer 实例（假设为consumer 1、consumer 2、consumer 3）时，一条消息投递过来，只会被consumer 1、consumer 2、consumer 3中的一个消费。

同时记住一点，使用集群消费的时候，consumer 的消费进度是存储在 broker 上，consumer 自身是不存储消费进度的。消息进度存储在 broker 上的好处在于，当你 consumer 集群是扩大或者缩小时，由于消费进度统一在broker上，消息重复的概率会被大大降低了。

### 广播消费

当 consumer 使用广播消费时，每条消息都会被 consumer 集群内所有的 consumer 实例消费一次，也就是说每条消息至少被每一个 consumer 实例消费一次。举个例子，当一个 consumer 集群内有 3 个 consumer 实例（假设为 consumer 1、consumer 2、consumer 3）时，一条消息投递过来，会被 consumer 1、consumer 2、consumer 3都消费一次。

与集群消费不同的是，**consumer 的消费进度是存储在各个 consumer 实例上**，这就容易造成消息重复。还有很重要的一点，对于广播消费来说，是不会进行消费失败重投的，所以在 consumer 端消费逻辑处理时，需要额外关注消费失败的情况。

虽然广播消费能保证集群内每个 consumer 实例都能消费消息，但是消费进度的维护、不具备消息重投的机制大大影响了实际的使用。因此，在实际使用中，更推荐使用集群消费，因为集群消费不仅拥有消费进度存储的可靠性，还具有消息重投的机制。而且，我们通过集群消费也可以达到广播消费的效果。

### **使用集群消费模拟广播消费**

如果业务上确实需要使用广播消费，那么我们可以通过创建多个 consumer 实例，每个 consumer 实例属于不同的 consumer group，但是它们都订阅同一个 topic。举个例子，我们创建 3 个 consumer 实例，consumer 1（属于consumer group 1）、consumer 2（属于 consumer group 2）、consumer 3（属于consumer group 3），它们都订阅了 topic A ，那么当 producer 发送一条消息到 topic A 上时，由于 3 个consumer 属于不同的 consumer group，所以 3 个consumer都能收到消息，也就达到了广播消费的效果了。 除此之外，每个 consumer 实例的消费逻辑可以一样也可以不一样，每个consumer group还可以根据需要增加 consumer 实例，比起广播消费来说更加灵活。

