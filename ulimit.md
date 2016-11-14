如果是root用户，打开文件数不够可以通过ulimit来设置，但是对于普通用户来说，似乎行不通，解决办法：
vi /etc/security/limits.conf
加上：
* soft nofile 65535
* hard nofile 65535
重新登录即可
用ulimit -n 修改open files 总是不能保持。所以用下面一个简单的办法更好些。

修改/etc/security/limits.conf 添加如下一行：

* - nofile 1006154

修改/etc/pam.d/login添加如下一行

session required /lib/security/pam_limits.so
