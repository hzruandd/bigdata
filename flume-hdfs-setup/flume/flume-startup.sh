#!/bin/bash

cd /var/www/flume/bin
nohup ./flume-ng agent --conf ../conf --conf-file ../conf/flume-conf.properties --name agent -Dflume.root.logger=INFO,console &
