##问题一

当使用spooldir时，指定目录下面不同出现两个相同名称的文件，否则出现
java.lang.IllegalStateException: File name has been re-used with different
files. Spooling assumptions violated for /var/log/flume/README.COMPLETED
错误，阻塞主线程，使其不能提供服务，只能重启agent了。


##问题二
使用同一个chanel，sink到logger和kafka，会出现卡死。

##kafka:
/vol_01/cloudera/parcels/KAFKA-2.0.0-1.kafka2.0.0.p0.12/bin/kafka-console-producer
--broker-list localhost:9092 --topic t1
Hi Hello
#[2016-10-14 01:24:02,381] ERROR Error when sending message to topic t1 with
#key: null, value: 8 bytes with error: Failed to update metadata after 60000 ms.
#(org.apache.kafka.clients.producer.internals.ErrorLoggingCallback)

confirm if you have the "Topic Auto Creation" disabled:
auto.create.topics.enable=false

can you check listener value in kafka.propertie 
 and try to change it from 
 
listeners=PLAINTEXT://hostname:9092
to
listeners=PLAINTEXT://0.0.0.0:9092

# kafka-configs --zookeeper 10.8.6.171:2181 --alter -delete-config                 
# listeners=PLAINTEXT://0.0.0.0:9092 --entity-type clients --entity-name test   
kafka-configs --zookeeper 10.8.6.171:2181 --alter --add-config                     
listeners=PLAINTEXT://0.0.0.0:9092 --entity-type clients --entity-name test

#在生产者指定broker-list时，只能ip:port,而不能hostname:port.
kafka-console-producer --broker-list 0.0.0.0:9092 --topic test

##使用Flume-ng1.6 spoolDir收集日志遇到的问题
#文件解码 
不能正确的重命名文件，抛出bug后，之后所有文件都不可以被flume收集，是一个比较
严重的错，引起原因是flume使用NIO方式读取文件，将读取的文件以UTF-8的编码读取，
在Linux状态下，默认是按照GBK编码方式存储文件，所以读取时就会遇到字符长度不够问题，
解决办法：在flume配置文件中设置监控目录中读取文件的编码方式。

#copy大文件抛出异常因为copy到spoolDir下的文件不可以被修改所致,解决方案：

使用scp或者cp备份文件，然后将文件mv进spoolDir下。还可以使用后缀名正则配合，
先拷贝进去.tmp的文件，等待copy完成后，rename文件名。

