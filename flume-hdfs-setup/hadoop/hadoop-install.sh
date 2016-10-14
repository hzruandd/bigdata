#!/bin/bash

cd /var/www

mkdir /var/www/hdfs

wget http://www.eng.lsu.edu/mirrors/apache/hadoop/core/hadoop-1.0.3/hadoop-1.0.3-bin.tar.gz

tar xzvf hadoop-1.0.3-bin.tar.gz

ln -sf /var/www/hadoop-1.0.3 hadoop

rm -rf /var/www/hadoop-1.0.3-bin.tar.gz




