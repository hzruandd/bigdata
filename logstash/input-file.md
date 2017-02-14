#配置示例

    input {
        file {
            path => ["/var/log/*.log", "/var/log/message"]
            type => "system"
            start_position => "beginning"
        }
    }

#有一些比较有用的配置项，可以用来指定 FileWatch 库的行为：
discover_interval

logstash 每隔多久去检查一次被监听的 path 下是否有新文件。默认值是 15 秒。

exclude 不想被监听的文件可以排除出去，这里跟 path 一样支持 glob 展开。

close_older 一个已经监听中的文件，如果超过这个值的时间内没有更新内容，就关闭监听它的文件句柄。默认是 3600 秒，即一小时。

ignore_older 在每次检查文件列表的时候，如果一个文件的最后修改时间超过这个值，就忽略这个文件。默认是 86400 秒，即一天。

sincedb_path 如果你不想用默认的 $HOME/.sincedb(Windows 平台上在 C:\Windows\System32\config\systemprofile\.sincedb)，可以通过这个配置定义 sincedb 文件到其他位置。

sincedb_write_interval logstash 每隔多久写一次 sincedb 文件，默认是 15 秒。

stat_interval logstash 每隔多久检查一次被监听文件状态（是否有更新），默认是 1 秒。

start_position logstash 从什么位置开始读取文件数据，默认是结束位置，也就是说 logstash 进程会以类似 tail -F 的形式运行。如果你是要导入原有数据，把这个设定改成 "beginning"，logstash 进程就从头开始读取，类似 less +F 的形式运行。
