#logstash无法实时处理很多文件(80万+，4k目录)的一次问题排查和记录

[Discuss the Elastic Stack](https://discuss.elastic.co/search)

[官放社区相关此问题的讨论贴]https://discuss.elastic.co/t/logstash-identitymapcodec-has-reached-100-capacity/40210/9

[identity map limit of 20k](https://github.com/logstash-plugins/logstash-codec-multiline/issues/25)

[Logstash crashed with
IdentityMapUpperLimitException](https://discuss.elastic.co/t/logstash-crashed-with-identitymapupperlimitexception/52394)

#many files 
[总的参考](https://github.com/elastic/logstash/pull/6169)

#根据以上资料做对应源代码调整后，仍然不能很好支持我们当下的需求，还需做一下调整
#./vendor/bundle/jruby/1.9/gems/logstash-input-file-4.0.0/lib/logstash/inputs/file.rb 
config :max_open_files, :validate => :number, :default => 65535 * 10

#./vendor/bundle/jruby/1.9/gems/filewatch-0.9.0/lib/filewatch/watch.rb
MAX_FILES_WARN_INTERVAL = ENV.fetch("FILEWATCH_MAX_FILES_WARN_INTERVAL",
655350).to_i


# Open file limit
LS_OPEN_FILES=1638400

# Nice level
LS_NICE=-1


./logstash-core/lib/logstash/pipeline.rb
#batch_size = @settings.get("pipeline.batch.size")
#batch_delay = @settings.get("pipeline.batch.delay")

#max_inflight = batch_size * pipeline_workers
batch_size = 33333
batch_delay = 10

max_inflight = batch_size * pipeline_workers

#vendor/bundle/jruby/1.9/gems/logstash-codec-multiline-3.0.3/lib/logstash/codecs/identity_map_codec.rb

    def visit(imc)
        current_size, limit = imc.current_size_and_limit
        limit = 1000000

#总结分析
第一，一般服务处理4k目录，800k文件都会很棘手，这也是为何logstash发展到5.0.0
版本依然没能很好支持超多文件的原因之一。当然了，这里需要自黑一下，一款服务每天
产生这么多个日志文件，也是不合理的（如果合理了，MySQL存储3亿条记录，就要写好几千万
个日志文件了，到底该如何做好日志，此处省略1000字）。

第二，遇到问题上面提到的问题后，就开始去查看logstash自身的log，发现当event接近20000
时（具体查看代码后，是超过80%就开始报警，写warn日志），就会频繁记录warn日志，
故，首先想到从这里入手。做法很简单粗暴把event设置更大。

第三，由于logstash需要监控的文件句柄确实太多，如果要保障可以work，那么必须就要“及时”
关闭一些文件句柄。此外还要把发现新文件句柄的加入时间设置大一点。但是此举肯定会造成
数据的延迟收集。

第四，需要ulimit去设置系统的文件句柄限制。

第五，需要去源代码里调整部分hard coding带来的限制（具体就不一一说明了）。

第六，通过以上调整后，logstash需要做一次全面的稳定性和性能测试，去验证以上的处理方案是否ok
以及做一些logstash本身的性能调优，参数调整等工作。
