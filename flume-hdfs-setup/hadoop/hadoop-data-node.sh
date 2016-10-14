#!/bin/bash

# modify the hdfs-site.xml

cd /var/www/hadoop/bin

./hadoop datanode -format
