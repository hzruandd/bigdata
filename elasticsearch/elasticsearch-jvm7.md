[Elasticsearch
Java虚拟机配置详解（转）](http://www.searchtech.pro/articles/2013/02/15/1360942226916.html)


Elasticsearch对Java虚拟机进行了预先的配置。通常情况下，因为这些配置的选择还是很谨慎的，所以你不需要太关心，并且你能立刻使用ElasticSearch。

但是，当你监视ElasticSearch节点内存时，你可能尝试修改一些配置。这些修改是否会改善你的处境？

这篇博文尝试揭开Elasticsearch配置的神秘面纱，并且讨论最常见的调整。最终，会给出一些推荐的配置调整。

Elasticsearch JVM 配置概览：

这些是Elasticsearch 0.19.11版本的默认配置。

JVM参数 Elasticsearch默认值 Environment变量
-Xms    256m    ES_MIN_MEM
-Xmx    1g  ES_MAX_MEM
-Xms and -Xmx       ES_HEAP_SIZE
-Xmn        ES_HEAP_NEWSIZE
-XX:MaxDirectMemorySize     ES_DIRECT_SIZE
-Xss    256k     
-XX:UseParNewGC +    
-XX:UseConcMarkSweepGC  +    
-XX:CMSInitiatingOccupancyFraction  75   
-XX:UseCMSInitiatingOccupancyOnly   +    
-XX:UseCondCardMark (commented out)
首先你注意到的是，Elasticsearch预留了256M到1GB的堆内存。

这个设置适用于开发和演示环境。开发人员只需要简单的解压发行包，再执行./bin/elasticsearch -f就完成了Elasticsearch的安装。当然这点对于开发来说非常棒，并且在很多场景下都能工作，但是当你需要更多内存来降低Elasticsearch负载的时候就不行了，你需要比2GB RAM更多的可用内存。

ES_MIN_MEM/ES_MAX_MEM是控制堆大小的配置。新的ES_HEAP_SIZE变量是一个更为便利的选择，因为将堆的初始大小和最大值设为相同。也推荐在分配堆内存时尽可能不要用内存的碎片。内存碎片对于性能优化来说非常不利。

ES_HEAP_NEWSIZE是可选参数，它控制堆的子集大小，也就是新生代的大小。

ES_DIRECT_SIZE控制本机直接内存大小，即JVM管理NIO框架中使用的数据区域大小。本机直接内存可以被映射到虚拟地址空间上，这样在64位的机器上更高效，因为可以规避文件系统缓冲。Elasticsearch对本机直接内存没有限制(可能导致OOM)。

由于历史原因Java虚拟机有多个垃圾收集器。可以通过以下的JVM参数组合启用：

JVM parameter   Garbage collector
-XX:+UseSerialGC    serial collector
-XX:+UseParallelGC  parallel collector
-XX:+UseParallelOldGC   Parallel compacting collector
-XX:+UseConcMarkSweepGC Concurrent-Mark-Sweep (CMS) collector
-XX:+UseG1GC    Garbage-First collector (G1)
UseParNewGC和UseConcMarkSweepGC组合启用垃圾收集器的并发多线程模式。UseConcMarkSweepGC自动选择UseParNewGC模式并禁用串行收集器（Serial collector）。在Java6中这是默认行为。

CMSInitiatingOccupancyFraction提炼了一种CMS（Concurrent-Mark-Sweep）垃圾收集设置；它将旧生代触发垃圾收集的阀值设为75.旧生代的大小是堆大小减去新生代大小。这告诉JVM当堆内容达到75%时启用垃圾收集。这是个估计的值，因为越小的堆可能需要越早启动GC。

UseCondCardMark将在垃圾收集器的card table使用时，在marking之前进行额外的判断，避免冗余的store操作。UseCondCardMark不影响Garbage-First收集器。强烈推荐在高并发场景下配置这个参数（规避card table marking技术在高并发场景下的降低吞吐量的负面作用）。在ElasticSearch中，这个参数是被注释掉的。

有些配置可以参考诸如Apache Cassandra项目，他们在JVM上有类似的需求。

总而言之，ElastciSearch配置上推荐：

1. 不采用自动的堆内存配置，将堆大小默认最大值设为1GB

2.调整触发垃圾收集的阀值，比如将gc设为75%堆大小的时候触发，这样不会影响性能。

3.禁用Java7默认的G1收集器，前提是你的ElasticSearch跑在Java7u4以上的版本上。

JVM进程的内存结果

JVM内存由几部分组成：

Java代码本身：包括内部代码、数据、接口，调试和监控代理或者字节码指令

非堆内存：用于加载类

栈内存：用于为每个线程存储本地变量和操作数

堆内存：用于存放对象引用和对象本身

直接缓冲区：用于缓冲I/O数据

堆内存的大小设置非常重要，因为Java的运行依赖于合理的堆大小，并且JVM需要从操作系统那获取有限的堆内存，用于支撑整个JVM生命周期。

如果堆太小，垃圾回收就会频繁发生，发生OOM的几率会很大。

如果堆太大，垃圾回收会延迟，但是一旦回收，就需要处理大量的存活堆数据。并且，操作系统的压力也会变大，因为JVM进程需要更大的堆，产生换页的可能性就会提高。

注意，使用CMS垃圾收集器，Java不会把内存还给操作系统，因此配置合理的堆初始值和最大值就非常重要。

非堆内存由Java应用自动分配。没有什么参数控制这里的大小，这是由Java应用程序代码自己决定的。

栈内存在每个线程中分配，在Elasticsearch中，每个线程大小必须由128K增加到256K，因为Java7比Java6需要更大的栈内存 ，这是由于Java7支持新的编程语言特征来利用栈空间。比如，引入了continuations模型，编程语言的一个著名概念。Continuations模型对于

协同程序、绿色线程（green thread）、纤程（fiber）非常有用 。当实现非阻塞I/O时，一个大的优势是，代码可以根据线程实际使用情况编写，但是运行时仍然在后台采用非阻塞I/O。Elasticsearch使用了多个线程池，因为Netty I/O框架和Guava是Elasticsearch的基础组件，因此在用Java7时，可以考虑进一步挖掘优化线程的特性。

发挥增加栈空间大小的优势还是有挑战的，因为不同的操作系统、不同的CPU架构，甚至在不同的JVM版本之间，栈空间的消耗不是容易比较的。取决于CPU架构和操作系统，JVM的栈空间大小是内建的。他们是否在所有场景下都适合？例如Sloaris Sparc 64位的JVM Xss默认为512K，因为有更大地址指针，Sloaris X86为320K。Linux降为256K。Windows 32位Java6默认320K，Windows 64位则为1024K。

大堆的挑战

今天，几GB的内存是很常见的。但是在不久以前，系统管理员还在为多几G的内存需求泪流满面。

Java垃圾收集器是随着2006年的Java6的出现而显著改进的。从那以后，可以并发执行多任务，并且减少了GC停顿几率： stop - the - world阶段。CMS算法是革命性的，多任务，并发， 不需要移动的GC。但是不幸的是，对于堆的存活数据量来说，它是不可扩展的。Prateek Khanna 和 Aaron Morton给出了CMS垃圾收集器能够处理的堆规模的数字。

避免Stop-the-world阶段

我们已经学习了Elasticsearch如何配置CMS垃圾收集器。但这并不能组织长时间的GC停顿，它只是降低了发生的几率。CMS是一个低停顿几率的收集器，但是仍然有一些边界情况。当堆上有MB级别的大数组，或者其他一些特殊的场景，CMS可能比预期要花费更多的时间。

MB级别数组的创建在Lucene segment-based索引合并时是很常见的。如果你希望降低CMS的额外负载，就需要调整Lucene合并阶段的段数量，使用参数index.merge.policy.segments_per_tier

减少换页

大堆的风险在于内存压力上。注意，如果Java JVM在处理大堆时，这部分内存对于系统其它部分来说是不可用的。如果内存吃紧，操作系统会进行换页，并且，在紧急情况下，当所有其他方式回收内存都失败时，会强制杀掉进程。如果换页发生，整个系统的性能会下降，自然GC的性能也跟着下降。所以，不要给堆分配太多的内存。

垃圾收集器的选择

从Java JDK 7u4开始，Garbage-First（G1）收集器是Java7默认的垃圾收集器。它适用于多核的机器以及大内存。它一方面降低了停顿时间，另一方面增加了停顿的次数。整个堆的操作，例如全局标记，是在应用线程中并发执行的。这会防止随着堆或存活数据大小的变化，中断时间也成比例的变化。

G1收集器目标是获取更高的吞吐量，而不是速度。在以下情况下，它能运行的很好：

1. 存活数据占用了超过50%的Java堆

2. 对象分配比例或者promotion会有明显的变化

3. 不希望gc或者compaction停顿时间长（超过0.5至1s）

注意，如果使用G1垃圾收集器，堆不再使用的内存可能会被归还给操作系统

G1垃圾收集器的不足是CPU使用率越高，应用性能越差。因此，如果在内存足够和CPU能力一般的情况下，CMS可能更胜一筹。

对于Elasticsearch来说，G1意味着没有长时间的stop-the-world阶段，以及更灵活的内存管理，因为buffer memory和系统I/O缓存能更充分的利用机器内存资源。代价就是小成本的最大化性能，因为G1利用了更多CPU资源。

性能调优策略

你读这篇博文因为你希望在性能调优上得到一些启示：

1. 清楚了解你的性能目标。你希望最大化速度，还是最大化吞吐量？

2. 记录任何事情（log everything），收集统计数据，阅读日志、分析事件来诊断配置

3. 选择你调整的目标（最大化性能还是最大化吞吐量）

4. 计划你的调整

5. 应用你的新配置

6. 监控新配置后的系统

7. 如果新配置没有改善你的处境，重复上面的一系列动作，反复尝试

Elasticsearch垃圾收集日志格式

Elasticsearch长时间GC下warns级别的日志如下所示：

[2012-11-26 18:13:53,166][WARN ][monitor.jvm              ] [Ectokid] [gc][ParNew][1135087][11248] duration [2.6m], collections [1]/[2.7m], total [2.6m]/[6.8m], memory [2.4gb]->[2.3gb]/[3.8gb], all_pools {[Code Cache] [13.7mb]->[13.7mb]/[48mb]}{[Par Eden Space] [109.6mb]->[15.4mb]/[1gb]}{[Par Survivor Space] [136.5mb]->[0b]/[136.5mb]}{[CMS Old Gen] [2.1gb]->[2.3gb]/[2.6gb]}{[CMS Perm Gen] [35.1mb]->[34.9mb]/[82mb]}

JvmMonitorService类中有相关的使用方式：

Logfile Explanation
gc  运行中的gc
ParNew  new parallel garbage collector
duration 2.6m   gc时间为2.6分钟
collections [1]/[2.7m]  在跑一个收集，共花2.7分钟
memory [2.4gb]->[2.3gb]/[3.8gb] 内存消耗, 开始是2.4gb, 现在是2.3gb, 共有3.8gb内存
Code Cache [13.7mb]->[13.7mb]/[48mb]    code cache占用内存
Par Eden Space [109.6mb]->[15.4mb]/[1gb]    Par Eden Space占用内存
Par Survivor Space [136.5mb]->[0b]/[136.5mb]    Par Survivor Space占用内存
CMS Old Gen [2.1gb]->[2.3gb]/[2.6gb]    CMS Old Gen占用内存
CMS Perm Gen [35.1mb]->[34.9mb]/[82mb]  CMS Perm Gen占用内存
JvmMonitorSer

一些建议

1. 不要在Java 6u22之前的发布版本中跑Elasticsearch。有内存方面的bug。那些超过两三年的bug和缺陷会妨碍Elasticsearch的正常运行。与旧的OpenJDK 6相比，更推荐Sun/Oracle的版本，因为后者修复了很多bug。

2. 放弃Java6，转到Java7。Oracle宣称Java6更新到2013年2月结束。考虑到Elasticsearch还是一个相对新的软件，应该使用更新的技术来提升性能。尽量从JVM中挤压性能。检查操作系统的版本。在最新版本的操作系统中运行，有助于你的Java运行环境达到最佳性能。

3. 定期更新Java运行环境。平均一个季度一次。告诉sa你需要及时更新Java版本，以获取Java性能的提升。

4. 从小到大。先在Elasticsearch单节点上进行开发。但是不要忘了Elasticsearch分布式的强大功能。单节点不能模拟生产环境的特征，至少需要3个节点进行开发测试。

5. 在调整JVM之前先做一下性能测试。对你的系统建立性能基线。调整测试时候的节点数量。如果索引时候负载很高，你可能需要降低Elasticsearch索引时候占用的堆大小，通过index.merge.policy.segments_per_tierparameter参数调整段的合并。

6. 调整前清楚你的性能目标，然后决定是调整速度还是吞吐量。

7. 启用日志以便更好的进行诊断。在优化系统前进行小心的评估。

8. 如果使用CMS垃圾收集器，你可能需要加上合理的 -XX:CMSWaitDuration 参数。

9. 如果你的堆超过6-8GB，超过了CMS垃圾收集器设计容量，你会遇到长时间的stop-the-world阶段，你有几个方案：调整CMSInitiatingOccupancyFraction参数降低长时间GC的几率减少最大堆的大小；启用G1垃圾收集器。

10. 学习垃圾收集调优艺术。如果你想精通的话，列出可用的JVM选项，在java命令中加入java-XX:+UnlockDiagnosticVMOptions -XX:+PrintFlagsFinal -version，然后调优。
