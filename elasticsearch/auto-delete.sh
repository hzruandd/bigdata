#!/bin/sh
# example: sh  auto-delete.sh logstash-kettle-log logsdate 30

index_name=$1
daycolumn=$2
savedays=$3
format_day=$4

if [ ! -n "$savedays" ]; then
  echo "the args is not right,please input again...."
  exit 1
fi

if [ ! -n "$format_day" ]; then
   format_day='%Y%m%d'
fi

sevendayago=`date -d "-${savedays} day " +${format_day}`

curl -XDELETE "10.130.3.102:9200/${index_name}/_query?pretty" -d "
{
        "query": {
                "filtered": {
                        "filter": {
                                "bool": {
                                        "must": {
                                                "range": {
                                                        "${daycolumn}": {
                                                                "from": null,
                                                                "to": ${sevendayago},
                                                                "include_lower": true,
                                                                "include_upper": true
                                                        }
                                                }
                                        }
                                }
                        }
                }
        }
}"

echo "ok"
