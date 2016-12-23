#http://kafka.apache.org/documentation/#basic_ops_increase_replication_factor


kafka-topics --delete --zookeeper 10.8.6.182:2181 --topic   real-demo-afe
kafka-topics  --zookeeper 10.8.6.182:2181 --list

kafka-reassign-partitions --zookeeper 10.8.6.182:2181 \
    --reassignment-json-file partitions-extension-push-token-topic.json
--execute

kafka-topics --zookeeper 10.8.6.182:2181 --create --topic my_topic_name
--partitions 20 --replication-factor 3



kafka-topics --zookeeper 10.8.6.182:2181  --alter  --partitions 40 --topic
my_topic_name

kafka-topics --zookeeper 10.8.6.182:2181  --alter --topic my_topic_name
--config x=y

kafka-topics --zookeeper 10.8.6.182:2181  --alter --topic my_topic_name
--delete-config x

kafka-topics --zookeeper 10.8.6.182:2181 --delete --topic my_topic_name

#Kafka does not currently support reducing the number of partitions for a
topic.

kafka-topics --zookeeper 10.8.6.182:2181 --delete --topic my_topic_name
--describe

#Limiting Bandwidth Usage during Data Migration
#it would move partitions at no more than 50MB/s
kafka-reassign-partitions --zookeeper 10.8.6.182:2181 --execute
--reassignment-json-file bigger-cluster.json —throttle 50000000 

#Should you wish to alter the throttle, during a rebalance, say to increase the
throughput so it completes quicker, you can do this by re-running the execute
command passing the same reassignment-json-file:
kafka-reassign-partitions --zookeeper 10.8.6.182:2181 --execute
--reassignment-json-file bigger-cluster.json —throttle 80000000

#When the --verify option is executed, and the reassignment has completed, the
script will confirm that the throttle was removed:

kafka-reassign-partitions --zookeeper 10.8.6.182:2181 --verify
--reassignment-json-file bigger-cluster.json

#To view the throttle limit configuration:
kafka-configs --describe  --zookeeper 10.8.6.182:2181  --entity-type clients

#To view the list of throttled replicas:
kafka-configs --describe  --zookeeper 10.8.6.182:2181  --entity-type topics
