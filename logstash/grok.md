#最佳实践

实际运用中，需要处理各种各样的日志文件，如果都是在配置文件里各自写一行自己的表达式，就完全不可管理了。所以，建议是把所有的grok 表达式统一写入到一个地方。然后用 filter/grok 的 patterns_dir 选项来指明。

如果把 "message" 里所有的信息都 grok
到不同的字段了，数据实质上就相当于是重复存储了两份。所以可以用 remove_field参数来删除掉 message 字段，或者用 overwrite 参数来重写默认的 message字段，只保留最重要的部分。

#重写参数的示例如下
    filter {
        grok {
            patterns_dir => "/path/to/your/own/patterns"
            match => {
                "message" => "%{SYSLOGBASE} %{DATA:message}"
            }
            overwrite => ["message"]
        }
    }

#多行匹配

在和 codec/multiline 搭配使用的时候，需要注意一个问题，grok
正则和普通正则一样，默认是不支持匹配回车换行的。就像你需要 =~ //m
一样也需要单独指定，具体写法是在表达式开始位置加 (?m) 标记。如下所示：
    match => {
    "message" => "(?m)\s+(?<request_time>\d+(?:\.\d+)?)\s+"
    }

#多项选择

有时候会碰上一个日志有多种可能格式的情况。这时候要写成单一正则就比较困难，或者全用
| 隔开又比较丑陋。这时候，logstash 的语法提供给一个有趣的解决方式。

文档中，都说明 logstash/filters/grok 插件的 match 参数应该接受的是一个 Hash
值。但是因为早期的 logstash 语法中 Hash 值也是用 []
这种方式书写的，所以其实现在传递 Array 值给 match
参数也完全没问题。所以，这里其实可以传递多个正则来匹配同一个字段：
    match => [
    "message", "(?<request_time>\d+(?:\.\d+)?)",
    "message", "%{SYSLOGBASE} %{DATA:message}",
    "message", "(?m)%{WORD}"
    ]
[调试自己的 grok 表达式](http://grokdebug.herokuapp.com/)
[Grok 支持把预定义的 grok 表达式 写入到文件中，官方提供的预定义 grok
表达式](https://github.com/elastic/logstash/tree/v1.4.2/patterns)

#自动生成grok表达式网站
#http://grokconstructor.appspot.com/ 

    input {
        file {
            type=>"test_grok"
            path=>["/data/logs/afa/**.log"]
            codec=> multiline {
            pattern => "(^.+Exception:.+)|(^\s+at .+)|(^\s+... \d                   +more)|(^\s*Caused by:.+)"
            what=> "previous"
                }
        }
    }
    
    filter {
            if [type] == "test_grok" {
               grok {
                     match => [ "message","%{SERVER_LOG}"]
                     patterns_dir => ["/opt/logstash/patterns",
                     "/opt/logstash/extra_patterns"]
                     remove_field => ["message"]
              }
            }
    }

    output {
        elasticsearch {
        host =>"xx-management"
        protocol =>"http"
        workers => 5
        template_overwrite => true
        }
        stdout { codec=> rubydebug }
    }
