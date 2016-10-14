#问题一

当使用spooldir时，指定目录下面不同出现两个相同名称的文件，否则出现
java.lang.IllegalStateException: File name has been re-used with different
files. Spooling assumptions violated for /var/log/flume/README.COMPLETED
错误，阻塞主线程，使其不能提供服务，只能重启agent了。


#问题二
使用同一个chanel，sink到logger和kafka，会出现卡死。
