#介绍一些基本信息

##channel
#memory--fast,but non-durable.
#file---reading,writing,mapping.
#jdbc---
#recoverablememory--A durable channel implementation that uses the local file system for its storage
#org.apache.flume.channel.PseudoTxnMemoryChannel--Mainly for testing purposes. Not meant for production use.


##source
#avro---Avro Netty RPC event source.
#exec---Execute a long-lived Unix process and read from stdout.
#netcat---Netcat style TCP event source.
#seq---Monotonically incrementing sequence generator event source.
#org.apache.flume.source.StressSource---Mainly for testing purposes. Not meant for production use..
#syslogtcp,syslogudp.
#org.apache.flume.source.avroLegacy.AvroLegacySource
#org.apache.flume.source.thriftLegacy.ThriftLegacySource
#org.apache.flume.source.scribe.ScribeSource

##sink
#hdfs---Writes all events received to HDFS (with support for rolling, bucketing, HDFS-200 append, and more).
#org.apache.flume.sink.hbase.HBaseSink---A simple sink that reads events from a channel and writes them to HBase.
#org.apache.flume.sink.hbase.AsyncHBaseSink---
#logger---Log events at INFO level via configured logging subsystem (log4j by default).
#avro---Sink that invokes a pre-defined Avro protocol method for all events it receives (when paired with an avro source, forms tiered collection).
#file_roll---RollingFileSink 
#null---/dev/null for Flume - blackhole all events received.


##ChannelSelector 
#replicating ，multiplexing ，

##SinkProcessor 
#default ，failover ，load_balance ，

##Interceptor$Builder---[more](http://flume.apache.org/FlumeUserGuide.html#flume-interceptors)
#[host](http://flume.apache.org/releases/content/1.2.0/apidocs/org/apache/flume/interceptor/HostInterceptor.html)，[timestamp](http://flume.apache.org/releases/content/1.2.0/apidocs/org/apache/flume/interceptor/TimestampInterceptor.html)，static ，regex_filter ，
##EventSerializer$Builder 
#text，avro_event 

##EventSerializer
#org.apache.flume.sink.hbase.SimpleHbaseEventSerializer,org.apache.flume.sink.hbase.SimpleAsyncHbaseEventSerializer,org.apache.flume.sink.hbase.RegexHbaseEventSerializer

##
