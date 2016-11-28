#读取文件

Logstash 使用一个名叫 FileWatch 的 Ruby Gem 库来监听文件变化。这个库支持 glob 展开文件路径，而且会记录一个叫 .sincedb 的数据库文件来跟踪被监听的日志文件的当前读取位置。所以，不要担心 logstash 会漏过你的数据。

sincedb 文件中记录了每个被监听的文件的 inode, major number, minor number 和 pos。

#注意

FileWatch 只支持文件的绝对路径，而且会不自动递归目录。所以有需要的话，请用数组方式都写明具体哪些文件。

LogStash::Inputs::File 只是在进程运行的注册阶段初始化一个 FileWatch 对象。所以它不能支持类似 fluentd 那样的 path => "/path/to/%{+yyyy/MM/dd/hh}.log" 写法。达到相同目的，你只能写成 path => "/path/to/*/*/*/*.log"。

start_position 仅在该文件从未被监听过的时候起作用。如果 sincedb 文件中已经有这个文件的 inode 记录了，那么 logstash 依然会从记录过的 pos 开始读取数据。所以重复测试的时候每回需要删除 sincedb 文件。

因为 windows 平台上没有 inode 的概念，Logstash 某些版本在 windows 平台上监听文件不是很靠谱。windows 平台上，推荐考虑使用 nxlog 作为收集端..

