#!/bin/bash

cd /var/www/hadoop/conf

# modify the hdfs-site.xml file
# modify the core-site.xml file
# modify the slaves file

cd /var/www/hadoop/bin

# format a new distributed filesystem
./hadoop namenode -format
