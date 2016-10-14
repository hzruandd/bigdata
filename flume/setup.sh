tar -zxvf apache-flume-1.6.0-bin.tar.gz
#配置系统环境变量：
vi /etc/profile  
  
添加：  
  
export FLUME_HOME=/home/{dir}/flume-1.6.0  
export FLUME_CONF_DIR=$FLUME_HOME/conf  
export PATH=$PATH:$FLUME_HOME/bin  

source /etc/profile 


