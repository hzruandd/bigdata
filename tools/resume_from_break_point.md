##通过flume已有功能实现一个断点续传，不丢失的日志收集器

#目标：
针对滚动的日志文件，实现断点续传、实时收集、日志滚动时不丢失、当然最重要的点是与应用解耦，无侵入性。

Flume的已有agent功能：

Flume默认已经提供了两种source：ExecSource执行系统命令tail
–F；另一种是spooldir。

tail
–F可实时收集日志。但是存在各种问题：比如agent进程意外挂掉了，启动后执行tail
–F的话会出现问题。

a、如果tail –F配置成从文件头开始读取：tail -n +0
–F。那很有可能此文件的前一部分，在agent挂掉前已经读取过了，这次又重读了一次；

b、如果tail –F配置成从文件头尾开始读取：tail -n 0
–F。那agent挂掉的这段时间内产生的日志数据，就读不到了。

c、另外tail –F在日志滚动的时候，会不会丢数据的风险呢。
测试过制作一个大文件app.log，然后tail –F从文件头开始读，还没有读完的时候，
模拟日志滚动，即大文件更换名字app.log.20161017，新创建文件app.log,
并且向app.log写入日志。这个时候tail –F就出错了：既不读取app.log.20161017也不读取app.log。

而spooldir的话，会监控日志目录下是否有新产生的日志文件，读取文件时要求文件内容不可变（这样做只能非实时）。即spooldir
读取app.log.20161017文件的日志，但是不能读取app.log的日志。

使用的时候可以配置不读取app.log：
    a1.sources.src-1.type = spooldir
    a1.sources.src-1.spoolDir = /var/log/apache/flumeSpool
    a1.sources.src-1.ignorePattern=app.log

spooldir的问题就是读取滚动后生成的日志文件，时效性差了：我们的文件如果按天滚动，
那不是就一天才能收集一次，最好的情况也就是按分钟滚动，这种情况会增加删除的负担，
而且会产生很多小文件。并且spooldir也不支持断点续传。

#在flume上实现支持断点续传、不丢日志的source设计思路：
定期检查日志目录下的日志文件的信息：
日志文件名称
日志文件长度
日志文件的dev值
inode值。

为什么要使用inode值：

由于日志滚动的时候会改变名字的，为了还能找到该文件，需要找一个唯一标识。

a、文件做rename，或者mv的时候，其inode值不变。

b、mv举例：比如app.log的inode=5914332，

执行mv app.log app.log.20161017，

app.log.20161017的inode还是5914332。

执行touch app.log之后新生成一个app.log文件，inode=5914357，是新的值了。

c、注：在同一个物理磁盘里面，mv文件到任何目录下，inode是不变的。不过将文件mv到另一个物理磁盘中，inode是会改变的。

根据dev和inode组合，来唯一标识文件。dev是文件所在磁盘的设备编号，inode是文件编号。不同磁盘下的两个文件可以inode值相同，但是dev值不同，所以我们使用dev和inode组合来唯一标识一个文件。

通过java nio的api可以获取文件的dev和inode信息。

    Path path = Paths.get("/xxx/log_dir/app.log");
    BasicFileAttributes bfa = Files.readAttributes(path,BasicFileAttributes.class);
    Object objectKey = bfa.fileKey();
    System.out.println("Object Key: " +bfa.fileKey()); 

#实时收集：新产生的文件offset为0。

消费之后记录该文件的dev、inode、offset到元数据文件。

日志文件滚动的时候名字变了，依然可以通过dev和inode找到它。

再次消费的时候对比之前记录的offset和文件最新的长度，来判断文件是否需要被消费。

#断点续传：如果agent异常挂掉，由于之前记录offset到元数据文件了，重新启动agent的时候，可以载入offset。

#不丢消息：滚动文件时，生成的文件app.log、app.log.
20161017都会被检查文件长度，每个文件长度和它已被消费的offset进行对比，进而得出是否需要消费该文件，达到日志滚动的时候也不会丢消息的目的。


