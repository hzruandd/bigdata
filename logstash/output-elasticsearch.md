#模板

Elasticsearch 支持给索引预定义设置和 mapping(前提是你用的 elasticsearch
版本支持这个 API，不过估计应该都支持)。Logstash
自带有一个优化好的模板，内容如下:
    {
    "template" : "logstash-*",
    "version" : 50001,
    "settings" : {
        "index.refresh_interval" : "5s"
    },
    "mappings" : {
        "_default_" : {
            "_all" : {"enabled" : true, "norms" : false},
            "dynamic_templates" : [ {
                "message_field" : {
                    "path_match" : "message",
                    "match_mapping_type" : "string",
                    "mapping" : {
                        "type" : "text",
                        "norms" : false
                    }
                }
            }, 
    {
     "string_fields" : {
         "match" : "*",
         "match_mapping_type" : "string",
         "mapping" : {
             "type" : "text", "norms" : false,
             "fields" : {
                 "keyword" : { "type": "keyword"  }
             }
         }
     }}],
    "properties" : {
        "@timestamp": { "type": "date", "include_in_all": false  },
        "@version": { "type": "keyword", "include_in_all": false  },
        "geoip"  : {
            "dynamic": true,
            "properties" : {
                "ip": { "type": "ip"  },
                "location" : { "type" : "geo_point"  },
                "latitude" : { "type" : "half_float"  },
                "longitude" : { "type" : "half_float"  }
            }
        }
    }
    }
    }
    }


这其中的关键设置包括：
##template for index-pattern
只有匹配 logstash-* 的索引才会应用这个模板。有时候我们会变更 Logstash 的默认索引名称，记住你也得通过 PUT 方法上传可以匹配你自定义索引名的模板。当然，我更建议的做法是，把你自定义的名字放在 "logstash-" 后面，变成 index => "logstash-custom-%{+yyyy.MM.dd}" 这样。

##refresh_interval for indexing

Elasticsearch 是一个近实时搜索引擎。它实际上是每 1 秒钟刷新一次数据。对于日志分析应用，我们用不着这么实时，所以 logstash 自带的模板修改成了 5 秒钟。你还可以根据需要继续放大这个刷新间隔以提高数据写入性能。

##multi-field with keyword

Elasticsearch 会自动使用自己的默认分词器(空格，点，斜线等分割)来分析字段。分词器对于搜索和评分是非常重要的，但是大大降低了索引写入和聚合请求的性能。所以 logstash 模板定义了一种叫"多字段"(multi-field)类型的字段。这种类型会自动添加一个 ".keyword" 结尾的字段，并给这个字段设置为不启用分词器。简单说，你想获取 url 字段的聚合结果的时候，不要直接用 "url" ，而是用 "url.keyword" 作为字段名。当你还对分词字段发起聚合和排序请求的时候，直接提示无法构建 fielddata 了！
在 Logstash 5.0 中，同时还保留携带了针对 Elasticsearch 2.x 的 template 文件，在那里，通过旧版本的 mapping 配置，达到和新版本相同的行为效果：对应统计字段明确设置 "index":"not_analyzed","doc_values":true，以及对分词字段加上对 fielddata 的 {"format":"disabled"}。

##geo_point

Elasticsearch 支持 geo_point 类型， geo distance 聚合等等。比如说，你可以请求某个 geo_point 点方圆 10 千米内数据点的总数。在 Kibana 的 tilemap 类型面板里，就会用到这个类型的数据。

##half_float

Elasticsearch 5.0 新引入了 half_float 类型。比标准的 float 类型占用更少的资源，提供更好的性能。在明确自己数值范围较小的时候可用。刚巧，经纬度就是一个明确的数值范围很小的数据。


##其他模板配置建议

###order
如果你有自己单独定制 template 的想法，很好。这时候有几种选择：
在 logstash/outputs/elasticsearch 配置中开启 manage_template => false 选项，然后一切自己动手；

在 logstash/outputs/elasticsearch 配置中开启 template => "/path/to/your/tmpl.json" 选项，让 logstash 来发送你自己写的 template 文件；

避免变更 logstash 里的配置，而是另外发送一个 template ，利用 elasticsearch 的 templates order 功能。
这个 order 功能，就是 elasticsearch 在创建一个索引的时候，如果发现这个索引同时匹配上了多个 template ，那么就会先应用 order 数值小的 template 设置，然后再应用一遍 order 数值高的作为覆盖，最终达到一个 merge 的效果。

比如，对上面这个模板已经很满意，只想修改一下 refresh_interval ，那么只需要新写一个：

    {
  "order" : 1,
  "template" : "logstash-*",
  "settings" : {
    "index.refresh_interval" : "20s"
  }
    }

然后运行 curl -XPUT http://localhost:9200/_template/template_newid -d '@/path/to/your/tmpl.json' 即可。

logstash 默认的模板， order 是 0，id 是 logstash，通过 logstash/outputs/elasticsearch 的配置选项 template_name 修改。你的新模板就不要跟这个名字冲突了。

