##主要优化原理和思路

kafka是一个高吞吐量分布式消息系统，并且提供了持久化。其高性能的有两个重要特点：

利用了磁盘连续读写性能远远高于随机读写的特点；

并发，将一个topic拆分多个partition。

要充分发挥kafka的性能，就需要满足这两个条件:


kafka读写的单位是partition，因此，将一个topic拆分为多个partition可以提高吞吐量。但是，这里有个前提，就是不同partition需 要位于不同的磁盘（可以
在同一个机器）。如果多个partition位于同一个磁盘，那么意味着有多个进程同时对一个磁盘的多个文 件进行读写，使得操作系统会对磁盘读写进行频繁调度，也就是破坏了磁盘读写的连续性。

在linkedlin的测试中，每台机器就加载了6个磁盘，并且不做raid，就是为了充分利用多磁盘并发读写，又保证每个磁盘连续读写 的特性。

具体配置上，是将不同磁盘的多个目录配置到broker的log.dirs，例如 

log.dirs=/disk1/kafka-logs,/disk2/kafka-logs,/disk3/kafka-logs 

kafka会在新建partition的时候，将新partition分布在partition最少的目录上，因此，一般不能将同一个磁盘的多个目录设置到log.dirs

同一个ConsumerGroup内的Consumer和Partition在同一时间内必须保证是一对一的消费关系

任意Partition在某一个时刻只能被一个Consumer Group内的一个Consumer消费(反过来一个Consumer则可以同时消费多个Partition)

##JVM参数配置
推荐使用最新的G1来代替CMS作为垃圾回收器。 
推荐使用的最低版本为JDK 1.7u51。下面是本次试验中Broker的JVM内存配置参数：
    -Xms26g -Xmx26g -XX:PermSize=48m -XX:MaxPermSize=48m -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35

#G1相比较于CMS的优势
G1是一种适用于服务器端的垃圾回收器，很好的平衡了吞吐量和响应能力。 

对于内存的划分方法不同，Eden, Survivor, Old区域不再固定，使用内存会更高效。G1通过对内存进行Region的划分，有效避免了内存碎片问题。

G1可以指定GC时可用于暂停线程的时间（不保证严格遵守）。而CMS并不提供可控选项。

CMS只有在FullGC之后会重新合并压缩内存，而G1把回收和合并集合在一起。

CMS只能使用在Old区，在清理Young时一般是配合使用ParNew，而G1可以统一两类分区的回收算法。

#G1的适用场景：

JVM占用内存较大(At least 4G)。

应用本身频繁申请、释放内存，进而产生大量内存碎片时。

对于GC时间较为敏感的应用。

[jvm调优总结](http://blog.csdn.net/lizhitao/article/details/44677659)

##Broker参数配置

配置优化都是修改server.properties文件中参数值

#网络和io操作线程配置优化
    # broker处理消息的最大线程数 
    num.network.threads=xxx 

    # broker处理磁盘IO的线程数 
    num.io.threads=xxx 

#建议配置：
用于接收并处理网络请求的线程数，默认为3。其内部实现是采用Selector模型。启动一个线程作为Acceptor来负责建立连接，再配合启动num.network.threads个线程来轮流负责从Sockets里读取请求，一般无需改动，除非上下游并发请求量过大。一般num.network.threads主要处理网络io，读写缓冲区数据，基本没有io等待，配置线程数量为cpu核数加1.

num.io.threads主要进行磁盘io操作，高峰期可能有些io等待，因此配置需要大些。配置线程数量为cpu核数2倍，最大不超过3倍。

#log数据文件刷盘策略 
为了大幅度提高producer写入吞吐量，需要定期批量写文件。 
#建议配置：
    # 每当producer写入10000条消息时，刷数据到磁盘 log.flush.interval.messages=10000

    # 每间隔1秒钟时间，刷数据到磁盘
    log.flush.interval.ms=1000

#日志保留策略配置

当kafka server的被写入海量消息后，会生成很多数据文件，且占用大量磁盘空间，如果不及时清理，可能磁盘空间不够用，kafka默认是保留7天。 
建议配置：

    # 保留三天，也可以更短 
    log.retention.hours=72

    # 段文件配置1GB，有利于快速回收磁盘空间，重启kafka加载也会加快(如果文件过小，则文件数量比较多，
    # kafka启动时是单线程扫描目录(log.dir)下所有数据文件)
    log.segment.bytes=1073741824

#Tips
Kafka官方并不建议通过Broker端的log.flush.interval.messages和log.flush.interval.ms来强制写盘，认为数据的可靠性应该通过Replica来保证，而强制Flush数据到磁盘会对整体性能产生影响。

可以通过调整/proc/sys/vm/dirty_background_ratio和/proc/sys/vm/dirty_ratio来调优性能。
    脏页率超过第一个指标会启动pdflush开始Flush Dirty PageCache。
    脏页率超过第二个指标会阻塞所有的写操作来进行Flush。
    根据不同的业务需求可以适当的降低dirty_background_ratio和提高dirty_ratio。

如果topic的数据量较小可以考虑减少log.flush.interval.ms和log.flush.interval.messages来强制刷写数据，减少可能由于缓存数据未写盘带来的不一致。

#Replica相关配置

    replica.lag.time.max.ms:10000

    replica.lag.max.messages:4000
    
    num.replica.fetchers:1
    #在Replica上会启动若干Fetch线程把对应的数据同步到本地，而num.replica.fetchers这个参数是用来控制Fetch线程的数量。
    #每个Partition启动的多个Fetcher，通过共享offset既保证了同一时间内Consumer和Partition之间的一对一关系，又允许我们通过增多Fetch线程来提高效率。
    
    
    default.replication.factor:1
    #这个参数指新创建一个topic时，默认的Replica数量
    #Replica过少会影响数据的可用性，太多则会白白浪费存储资源，一般建议在2~3为宜。

#purgatory
    fetch.purgatory.purge.interval.requests:1000
    producer.purgatory.purge.interval.requests:1000

首先来介绍一下这个“炼狱”究竟是用来做什么用的。Broker的一项主要工作就是接收并处理网络上发来的Request。这些Request其中有一些是可以立即答复的，那很自然这些Request会被直接回复。另外还有一部分是没办法或者Request自发的要求延时答复（例如发送和接收的Batch）,Broker会把这种Request放入Paurgatory当中，同时每一个加入Purgatory当中的Request还会额外的加入到两个监控对队列：

WatcherFor队列：用于检查Request是否被满足。
DelayedQueue队列：用于检测Request是否超时。

Request最终的状态只有一个，就是Complete。请求被满足和超时最终都会被统一的认为是Complete。

目前版本的Purgatory设计上是存在一定缺陷的。Request状态转变为Complete后，并没能立即从Purgatory中移除，而是继续占用资源，因此占用内存累积最终会引发OOM。这种情况一般只会在topic流量较少的情况下触发。更详细的资料可以查阅扩展阅读，在此不做展开。

Kafka的研发团队已经开始着手重新设计Purgatory，力求能够让Request在Complete时立即从Purgatory中移除。

#其他调整

    num.partitions:1
    #分区数量
    
    queued.max.requests:500
    #这个参数是指定用于缓存网络请求的队列的最大容量，这个队列达到上限之后将不再接收新请求。一般不会成为瓶颈点，除非I/O性能太差，这时需要配合num.io.threads等配
    置一同进行调整。
    
    compression.codec:none
    #Message落地时是否采用以及采用何种压缩算法。一般都是把Producer发过来Message直接保存，不再改变压缩方式。
    
    in.insync.replicas:1
    #这个参数只能在topic层级配置，指定每次Producer写操作至少要保证有多少个在ISR的Replica确认，一般配合request.required.acks使用。要注意，这个参
    数如果设置的过高可能会大幅降低吞吐量。

#Producer优化
    buffer.memory:33554432 (32m)
    #在Producer端用来存放尚未发送出去的Message的缓冲区大小。缓冲区满了之后可以选择阻塞发送或抛出异常，由block.on.buffer.full的配置来决定。
    
    compression.type:none
    #默认发送不进行压缩，推荐配置一种适合的压缩算法，可以大幅度的减缓网络压力和Broker的存储压力。
    
    
    linger.ms:0
    #Producer默认会把两次发送时间间隔内收集到的所有Requests进行一次聚合然后再发送，以此提高吞吐量，而linger.ms则更进一步，这个参数为每次发送增加一些delay，
    以此来聚合更多的Message。
    
    batch.size:16384
    #Producer会尝试去把发往同一个Partition的多个Requests进行合并，batch.size指明了一次Batch合并后Requests总大小的上限。如果这个值设置
    的太小，可能会导致所有的Request都不进行Batch。
    
    acks:1
    #这个配置可以设定发送消息后是否需要Broker端返回确认。
    
    0: 不需要进行确认，速度最快。存在丢失数据的风险。
    1: 仅需要Leader进行确认，不需要ISR进行确认。是一种效率和安全折中的方式。
    all: 需要ISR中所有的Replica给予接收确认，速度最慢，安全性最高，但是由于ISR可能会缩小到仅包含一个Replica，所以设置参数为all并不能一定避免数据丢失。

#Consumer优化
    num.consumer.fetchers:1
    #启动Consumer的个数，适当增加可以提高并发度。
    
    
    fetch.min.bytes:1
    #每次Fetch Request至少要拿到多少字节的数据才可以返回。
    
    #在Fetch Request获取的数据至少达到fetch.min.bytes之前，允许等待的最大时长。对应上面说到的Purgatory中请求的超时时间。
    fetch.wait.max.ms:100

通过Consumer Group，可以支持生产者消费者和队列访问两种模式。

Consumer API分为High level和Low level两种。前一种重度依赖Zookeeper，所以性能差一些且不自由，但是超省心。第二种不依赖Zookeeper服务，无论从自由度和性能上都有更好的表现，但是所有的异常(Leader迁移、Offset越界、Broker宕机等)和Offset的维护都需要自行处理。

[broker默认参数及可配置所有参数列表](http://blog.csdn.net/lizhitao/article/details/25667831)

[kafka原理、基本概念，broker，producer，consumer，topic所有参数配置列表](http://blog.csdn.net/suifeng3051/article/details/48053965)

[Kafka深度解析](http://www.jasongj.com/2015/01/02/Kafka%E6%B7%B1%E5%BA%A6%E8%A7%A3%E6%9E%90/)

[官方文档](http://kafka.apache.org/documentation.html#configuration)


