##免密码ssh

在搭建Hadoop集群时，需要机器相互可以免密码ssh，操作如下（所有机器都要操作）：

#ssh-keygen -t rsa

将产生的公钥复制到第一台机器 
# scp ~/.ssh/id_rsa.pub root@host:~/id_rsa.pub.1
将所有密钥追加到authorized_keys中： 
# cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys 
# cat ~/id_rsa.pub.1 >> ~/.ssh/authorized_keys 
# cat ~/id_rsa.pub.2 >> ~/.ssh/authorized_keys 
# cat ~/id_rsa.pub.3 >> ~/.ssh/authorized_keys 
…
修改authorized_keys权限 
# chmod 700 ~/.ssh 
# chmod 600 ~/.ssh/authorized_keys
分发到集群的各个机器： 
# scp ~/.ssh/authorized_keys root@host1:~/.ssh/authorized_keys 
# scp ~/.ssh/authorized_keys root@host2:~/.ssh/authorized_keys 
# scp ~/.ssh/authorized_keys root@host3:~/.ssh/authorized_keys
