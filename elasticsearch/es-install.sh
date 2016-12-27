#!/bin/bash
#************************************************************************************************
# Title: install_elasticsearch  - ES单机部署
#
# Parameters:  
#   INSTALL_PATH     - ES部署目录
#   ES_NODE_NUM      - ES节点编号
#   ES_LOCAL_IP      - ES节点IP
#   ES_IP_LIST       - ES集群节点IP列表
#   ES_CLUSTER_NAME  - ES集群名
#   HTTP_PORT        - ES节点的HTTP端口
#   ES_NODE_TYPE     - ES节点类型
#   ES_VERSION       - ES版本号
# Example:
#   1) ./es-install.sh . 1 127.0.0.1 127.0.0.1,127.0.0.2,127.0.0.3 xm-search 8412 DATA 1.7.3
#************************************************************************************************

#==============================
#1. 预处理：解析安装脚本参数
#==============================
if [ $# -lt 5 ];
then
    echo -e "\033[31m<WARN> USAGE:\n    /bin/bash es-install.sh <INSTALL_PTAH> <ES_NODE_NUM>\033[0m"
    echo -e "\033[31m                                           <ES_LOCAL_IP> <ES_IP_LIST> <ES_CLUSTER_NAME>\033[0m"
    echo -e "\033[31m                                           <HTTP_PORT> <ES_NODE_TYPE> <ES_VERSION>\033[0m"
    exit 1
fi

if [ $# -lt 6 ]
then
    echo -e "<INFO> USE default HTTP_PORT : 9200 && default ES_VERSION : 1.7.3 && default node type : DATA."
    INSTALL_PATH=$1
    ES_NODE_NUM=$2
    ES_LOCAL_IP=$3
    ES_IP_LIST=$4
    ES_CLUSTER_NAME=$5
    HTTP_PORT="9200"
    ES_NODE_TYPE="DATA"
    ES_VERSION="1.7.3"
elif [ $# -eq 6 ]
then
    echo -e "<INFO> USE default ES_VERSION : 1.7.3 && default node type : DATA."
    INSTALL_PATH=$1
    ES_NODE_NUM=$2
    ES_LOCAL_IP=$3
    ES_IP_LIST=$4
    ES_CLUSTER_NAME=$5
    HTTP_PORT=$6
    ES_NODE_TYPE="DATA"
    ES_VERSION="1.7.3"
elif [ $# -eq 7  ]
then
    echo -e "<INFO> USE default ES_VERSION : 1.7.3."
    INSTALL_PATH=$1
    ES_NODE_NUM=$2
    ES_LOCAL_IP=$3
    ES_IP_LIST=$4
    ES_CLUSTER_NAME=$5
    HTTP_PORT=$6
    ES_NODE_TYPE=$7
    ES_VERSION="1.7.3"
else
    INSTALL_PATH=$1
    ES_NODE_NUM=$2
    ES_LOCAL_IP=$3
    ES_IP_LIST=$4
    ES_CLUSTER_NAME=$5
    HTTP_PORT=$6
    ES_NODE_TYPE=$7
    ES_VERSION=$8
fi

if [ ${ES_NODE_TYPE}"x" = "MASTERx" ]
then
    ES_NODE_TYPE="MASTER"
elif [ ${ES_NODE_TYPE}"x" = "DMx"  ]
then
    ES_NODE_TYPE="MASTERDATA"
else
    ES_NODE_TYPE="DATA"
fi

LEN=`echo ${ES_NODE_NUM} | awk '{print length($0)}'`

if [ ${LEN}"x" = "0x"  ]
then
    ES_NODE_NUM="00"
elif [ ${LEN}"x" = "1x"  ]
then
    ES_NODE_NUM="0"${ES_NODE_NUM}
fi

if [ ! -n $INSTALL_PATH ];
then
    echo -e "\033[31m<INFO> var INSTALL_PATH is NULL\033[0m"
    exit 1
fi

if [ ! -n $ES_VERSION ];
then
    echo -e "\033[31m<INFO> var INSTALL_PATH is NULL\033[0m"
    exit 1
fi

if [ ! -n $ES_NODE_TYPE ];
then
    echo -e "\033[31m<INFO> var ES_NODE_TYPE is NULL\033[0m"
    exit 1
fi

if [ ! -n $ES_NODE_NUM ];
then
    echo -e "\033[31m<INFO> var ES_NODE_NUM is NULL\033[0m"
    exit 1
fi

if [ ! -n $ES_LOCAL_IP ];
then
    echo -e "\033[31m<INFO> var ES_LOCAL_IP is NULL\033[0m"
    exit 1
fi

if [ ! -n $ES_IP_LIST ];
then
    echo -e "\033[31m<INFO> var ES_IP_LIST is NULL\033[0m"
    exit 1
fi

if [ ! -n $ES_CLUSTER_NAME ];
then
    echo -e "\033[31m<INFO> var ES_CLUSTER_NAME is NULL\033[0m"
    exit 1
fi


#==============================
#2. 下载安装包
#==============================
DOWNLOAD_URL="https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-"${ES_VERSION}".tar.gz"
cd ${INSTALL_PATH}

#判断目录底下是否存在安装包
XFLAG=`ls -al | grep -i "elasticsearch-${ES_VERSION}.tar.gz" | wc -l`

if [ ${XFLAG} -eq 1  ];
then
    tar -zxf elasticsearch-${ES_VERSION}.tar.gz
    #rm -rf "elasticsearch-"${ES_VERSION}".tar.gz"
else
    echo -e "<INFO> Download Elasticsearch_${ES_VERSION} start......"
    curl -L -O  ${DOWNLOAD_URL}
    echo -e "<INFO> Download Elasticsearch_${ES_VERSION} success...... "

    XYFLAG=`ls -al | grep -i "elasticsearch-${ES_VERSION}.tar.gz" | wc -l`
    
    if [ ${XYFLAG} -eq 1  ];
    then
        tar -zxf elasticsearch-${ES_VERSION}.tar.gz
        #rm -rf "elasticsearch-"${ES_VERSION}".tar.gz"
    else
        echo -e "\033[31m<INFO> Can not find install source.\033[0m"
    fi
fi



#=============================
#3. 修改集群配置文件
#=============================
cd "elasticsearch-"${ES_VERSION}
BASE_PATH=`pwd`

DATA_PATH=${BASE_PATH}"/data"
LOGS_PATH=${BASE_PATH}"/logs"
WORK_PATH=${BASE_PATH}"/work"
PLUGINS_PATH=${BASE_PATH}"/plugins"

SYSTEM_TYPE=`uname`

if [ ${SYSTEM_TYPE}"x" = "Linuxx"  ] 
then
    SYSTEM_TYPE="L"
else
    SYSTEM_TYPE="M"
fi

if [ ! -d ${DATA_PATH}  ]
then
    mkdir ${DATA_PATH}
fi

if [ ! -d ${LOGS_PATH}  ]
then
    mkdir ${LOGS_PATH}
fi

if [ ! -d ${WORK_PATH}  ]
then
    mkdir ${WORK_PATH}
fi

if [ ! -d ${PLUGINS_PATH}  ]
then
    mkdir ${PLUGINS_PATH}
fi

CONFIG_FILE=${BASE_PATH}"/config/elasticsearch.yml"
LOG_CONFIG_FILE=${BASE_PATH}"/config/logging.yml"
MEM_CONFIG_FILE=${BASE_PATH}"/bin/elasticsearch.in.sh"

CLUSTER_NAME=${ES_CLUSTER_NAME}

echo -e "<INFO> Modify ES config in ${ES_NODE_TYPE} mode start......"


#修改通用配置参数
if [ ${SYSTEM_TYPE}"x" = "Lx"  ]
then
    echo "--------LINUX--------"
    sed -i "s/#cluster.name: elasticsearch/cluster.name: ${CLUSTER_NAME}/g" ${CONFIG_FILE}
    sed -i "s/#node.name: \"Franz Kafka\"/node.name: \"${CLUSTER_NAME}-${ES_NODE_NUM}\"/g" ${CONFIG_FILE}
    sed -i "s?#path.data: .*?path.data: ${DATA_PATH}?" ${CONFIG_FILE}
    sed -i "s?#path.work: .*?path.work: ${WORK_PATH}?" ${CONFIG_FILE}
    sed -i "s?#path.logs: .*?path.logs: ${LOGS_PATH}?" ${CONFIG_FILE}
    sed -i "s?#path.plugins: .*?path.plugins: ${PLUGINS_PATH}?" ${CONFIG_FILE}
    sed -i "s/#bootstrap.mlockall/bootstrap.mlockall/g" ${CONFIG_FILE}
    sed -i "s/#http.port: 9200/http.port: ${HTTP_PORT}/g" ${CONFIG_FILE}
    sed -i "s/#discovery.zen.ping.multicast.enabled/discovery.zen.ping.multicast.enabled/g" ${CONFIG_FILE}
else
    echo "---------MAC---------"
    sed -i "" "s/#cluster.name: elasticsearch/cluster.name: ${CLUSTER_NAME}/g" ${CONFIG_FILE}
    sed -i "" "s/#node.name: \"Franz Kafka\"/node.name: \"${CLUSTER_NAME}-${ES_NODE_NUM}\"/g" ${CONFIG_FILE}
    sed -i "" "s?#path.data: .*?path.data: ${DATA_PATH}?" ${CONFIG_FILE}
    sed -i "" "s?#path.work: .*?path.work: ${WORK_PATH}?" ${CONFIG_FILE}
    sed -i "" "s?#path.logs: .*?path.logs: ${LOGS_PATH}?" ${CONFIG_FILE}
    sed -i "" "s?#path.plugins: .*?path.plugins: ${PLUGINS_PATH}?" ${CONFIG_FILE}
    sed -i "" "s/#bootstrap.mlockall/bootstrap.mlockall/g" ${CONFIG_FILE}
    sed -i "" "s/#http.port: 9200/http.port: ${HTTP_PORT}/g" ${CONFIG_FILE}
    sed -i "" "s/#discovery.zen.ping.multicast.enabled/discovery.zen.ping.multicast.enabled/g" ${CONFIG_FILE}
fi

#修改指定配置参数[是否是Master节点等]
if [ ${ES_NODE_TYPE}"x" = "DATAx" ]
then
    if [ ${SYSTEM_TYPE}"x" = "Lx"  ]
    then
        sed -i "1,/#node.data: true/{s/#node.data: true/node.data: true/}" ${CONFIG_FILE}
        sed -i "1,/#node.master: false/{s/#node.master: false/node.master: false/}" ${CONFIG_FILE}
    else
        sed -i "" "s/#node.data: true/node.data: true/" ${CONFIG_FILE}
        sed -i "" "s/#node.master: false/node.master: false/" ${CONFIG_FILE}
    fi
elif [ ${ES_NODE_TYPE}"x" = "MASTERx" ]
then
    if [ ${SYSTEM_TYPE}"x" = "Lx"  ]
    then
        sed -i "1,/#node.data: flase/{s/#node.data: flase/node.data: flase/}" ${CONFIG_FILE}
        sed -i "1,/#node.master: true/{s/#node.master: true/node.master: true/}" ${CONFIG_FILE}
    else
        sed -i "" "s/#node.data: flase/node.data: flase/" ${CONFIG_FILE}
        sed -i "" "s/#node.master: true/node.master: true/" ${CONFIG_FILE}
    fi
elif [ ${ES_NODE_TYPE}"x" = "MASTERDATAx" ] 
then
    if [ ${SYSTEM_TYPE}"x" = "Lx"  ]
    then
        sed -i "1,/#node.data: true/{s/#node.data: true/node.data: true/}" ${CONFIG_FILE}
        sed -i "1,/#node.master: true/{s/#node.master: true/node.master: true/}" ${CONFIG_FILE}
    else
        sed -i "" "s/#node.data: true/node.data: true/" ${CONFIG_FILE}
        sed -i "" "s/#node.master: true/node.master: true/" ${CONFIG_FILE}
    fi
else
    if [ ${SYSTEM_TYPE}"x" = "Lx"  ]
    then
        sed -i "1,/#node.data: true/{s/#node.data: true/node.data: true/}" ${CONFIG_FILE}
        sed -i "1,/#node.master: false/{s/#node.master: false/node.master: false/}" ${CONFIG_FILE}
    else
        sed -i "" "s/#node.data: true/node.data: true/" ${CONFIG_FILE}
        sed -i "" "s/#node.master: false/node.master: false/" ${CONFIG_FILE}
    fi
fi

#修改相关的配置参数
if [ ${SYSTEM_TYPE}"x" = "Lx"  ]
then
    sed -i "s/#network.host: .*/network.host: ${ES_LOCAL_IP}/g" ${CONFIG_FILE}
else
    sed -i "" "s/#network.host: .*/network.host: ${ES_LOCAL_IP}/g" ${CONFIG_FILE}
fi

LIST=${ES_IP_LIST//,/ }
REMAIN='['
for ele in ${LIST}
do
    if [ ${ele}"x" != ${ES_LOCAL_IP}"x" ]
    then
        if [ ${REMAIN} = '[' ]
        then
            REMAIN=${REMAIN}'"'${ele}'"'
        else
            REMAIN=${REMAIN}',"'${ele}'"'
        fi
    fi
done
REMAIN=${REMAIN}"]"

if [ ${SYSTEM_TYPE}"x" = "Lx"  ]
then
    if [ ${REMAIN}"x" = "[]x"  ]
    then
        echo -e "<WARN> ES Cluster has single node : ${ES_LOCAL_IP}."
    else
        sed -i "s/#discovery.zen.ping.unicast.hosts: .*/discovery.zen.ping.unicast.hosts: ${REMAIN}/g" ${CONFIG_FILE}
    fi
else
    if [ ${REMAIN}"x" = "[]x"  ]
    then
        echo -e "<WARN> ES Cluster has single node : ${ES_LOACL_IP}."
    else
        sed -i "" "s/#discovery.zen.ping.unicast.hosts: .*/discovery.zen.ping.unicast.hosts: ${REMAIN}/g" ${CONFIG_FILE}
    fi
fi


CACHE_CONFIG="\n\n\n\n# 缓存类型设置为Soft Reference，只有当内存不够时才会进行回收\nindex.cache.field.max_size: 50000\nindex.cache.field.expire: 10m\nindex.cache.field.type: soft"
CACHE_CONFIG=${CACHE_CONFIG}"\n\naction.auto_create_index: false"
echo -e ${CACHE_CONFIG} >> ${CONFIG_FILE}


#修改ES节点内存参数
if [ ${SYSTEM_TYPE}"x" = "Lx"  ]
then
    TOTAL_MEM=`cat /proc/meminfo |grep 'MemTotal' |awk -F : '{print $2}' |awk -F ' ' '{print $1}'`
    TOTAL_MEM=`echo ${TOTAL_MEM}"/1000/1000" | bc`

    VAR1=`echo ${TOTAL_MEM}"/2" | bc`

    if [ ${VAR1}"x" = "x" ]
    then
        VAR1=1
    fi
    
    if [ ${VAR1} -gt 4  ]
    then
        VAR1=4
    elif [ ${VAR1} -gt 2  ]
    then
        VAR1=2
    else
        VAR1=1
    fi
    
    TOTAL_MEM=${VAR1}"g"
else
    TOTAL_MEM="1g"
fi



if [ ${SYSTEM_TYPE}"x" = "Lx"  ]
then
    sed -i "/ES_CLASSPATH=$ES_CLASSPATH/a\ES_HEAP_SIZE=${TOTAL_MEM}" ${MEM_CONFIG_FILE}
else
    sed -i "" "2s/.*/ES_HEAP_SIZE=${TOTAL_MEM}/" ${MEM_CONFIG_FILE}
fi


echo -e "<INFO> Modify ES config in ${ES_NODE_TYPE} mode success......"



#=============================
#4. 修改日志配置文件
#=============================
QUERY_WARN="1s"
QUERY_INFO="500ms"
QUERY_DEBUG="100ms"
QUERY_TRACE="1ms"

FETCH_WARN="1s"
FETCH_INFO="500ms"
FETCH_DEBUG="100ms"
FETCH_TRACE="1ms"

INDEX_WARN="1s"
INDEX_INFO="500ms"
INDEX_DEBUG="100ms"
INDEX_TRACE="1ms"

if [ ${SYSTEM_TYPE}"x" = "Lx"  ]
then
    sed -i "s/#index.search.slowlog.threshold.query.warn: .*/index.search.slowlog.threshold.query.warn: ${QUERY_WARN}/g" ${CONFIG_FILE}
    sed -i "s/#index.search.slowlog.threshold.query.info: .*/index.search.slowlog.threshold.query.info: ${QUERY_INFO}/g" ${CONFIG_FILE}
    sed -i "s/#index.search.slowlog.threshold.query.debug: .*/index.search.slowlog.threshold.query.debug: ${QUERY_DEBUG}/g" ${CONFIG_FILE}
    sed -i "s/#index.search.slowlog.threshold.query.trace: .*/index.search.slowlog.threshold.query.trace: ${QUERY_TRACE}/g" ${CONFIG_FILE}

    sed -i "s/#index.search.slowlog.threshold.fetch.warn: .*/index.search.slowlog.threshold.fetch.warn: ${FETCH_WARN}/g" ${CONFIG_FILE}
    sed -i "s/#index.search.slowlog.threshold.fetch.info: .*/index.search.slowlog.threshold.fetch.info: ${FETCH_INFO}/g" ${CONFIG_FILE}
    sed -i "s/#index.search.slowlog.threshold.fetch.debug: .*/index.search.slowlog.threshold.fetch.debug: ${FETCH_DEBUG}/g" ${CONFIG_FILE}
    sed -i "s/#index.search.slowlog.threshold.fetch.trace: .*/index.search.slowlog.threshold.fetch.trace: ${FETCH_TRACE}/g" ${CONFIG_FILE}

    sed -i "s/#index.indexing.slowlog.threshold.index.warn: .*/index.indexing.slowlog.threshold.index.warn: ${INDEX_WARN}/g" ${CONFIG_FILE}
    sed -i "s/#index.indexing.slowlog.threshold.index.info: .*/index.indexing.slowlog.threshold.index.info: ${INDEX_INFO}/g" ${CONFIG_FILE}
    sed -i "s/#index.indexing.slowlog.threshold.index.debug: .*/index.indexing.slowlog.threshold.index.debug: ${INDEX_DEBUG}/g" ${CONFIG_FILE}
    sed -i "s/#index.indexing.slowlog.threshold.index.trace: .*/index.indexing.slowlog.threshold.index.trace: ${INDEX_TRACE}/g" ${CONFIG_FILE}
else
    sed -i "" "s/#index.search.slowlog.threshold.query.warn: .*/index.search.slowlog.threshold.query.warn: ${QUERY_WARN}/g" ${CONFIG_FILE}
    sed -i "" "s/#index.search.slowlog.threshold.query.info: .*/index.search.slowlog.threshold.query.info: ${QUERY_INFO}/g" ${CONFIG_FILE}
    sed -i "" "s/#index.search.slowlog.threshold.query.debug: .*/index.search.slowlog.threshold.query.debug: ${QUERY_DEBUG}/g" ${CONFIG_FILE}
    sed -i "" "s/#index.search.slowlog.threshold.query.trace: .*/index.search.slowlog.threshold.query.trace: ${QUERY_TRACE}/g" ${CONFIG_FILE}

    sed -i "" "s/#index.search.slowlog.threshold.fetch.warn: .*/index.search.slowlog.threshold.fetch.warn: ${FETCH_WARN}/g" ${CONFIG_FILE}
    sed -i "" "s/#index.search.slowlog.threshold.fetch.info: .*/index.search.slowlog.threshold.fetch.info: ${FETCH_INFO}/g" ${CONFIG_FILE}
    sed -i "" "s/#index.search.slowlog.threshold.fetch.debug: .*/index.search.slowlog.threshold.fetch.debug: ${FETCH_DEBUG}/g" ${CONFIG_FILE}
    sed -i "" "s/#index.search.slowlog.threshold.fetch.trace: .*/index.search.slowlog.threshold.fetch.trace: ${FETCH_TRACE}/g" ${CONFIG_FILE}

    sed -i "" "s/#index.indexing.slowlog.threshold.index.warn: .*/index.indexing.slowlog.threshold.index.warn: ${INDEX_WARN}/g" ${CONFIG_FILE}
    sed -i "" "s/#index.indexing.slowlog.threshold.index.info: .*/index.indexing.slowlog.threshold.index.info: ${INDEX_INFO}/g" ${CONFIG_FILE}
    sed -i "" "s/#index.indexing.slowlog.threshold.index.debug: .*/index.indexing.slowlog.threshold.index.debug: ${INDEX_DEBUG}/g" ${CONFIG_FILE}
    sed -i "" "s/#index.indexing.slowlog.threshold.index.trace: .*/index.indexing.slowlog.threshold.index.trace: ${INDEX_TRACE}/g" ${CONFIG_FILE}
fi



#=================================
#5. 安装各种插件[head,bigdesk,paramedic]
#=================================
BIN_PATH=${BASE_PATH}"/bin"
PLUGIN=${BIN_PATH}"/plugin"

cd ${BIN_PATH}


if [ ${ES_NODE_TYPE}"x" = "MASTERx"  ] || [ ${ES_NODE_TYPE}"x" = "MASTERDATAx"  ]
then
    echo -e "<INFO> Install plugin HEAD start......"
    ${PLUGIN} -install mobz/elasticsearch-head
    echo -e "<INOF> Install plugin HEAD finished..."
    
    #echo -e "<INFO> Install plugin BIGDESK start......"
    #${PLUGIN} -install lukas-vlcek/bigdesk/2.4.0
    #echo -e "<INFO> Install plugin BIGDESK finished..."
    
    #echo -e "<INFO> Install plugin Paramedic start......"
    #${PLUGIN} -install karmi/elasticsearch-paramedic
    #echo -e "<INFO> Install plugin Paramedic finished..."
fi


#=================================
#6. 安装IK分词器
#=================================
echo -e "<INFO> Install IK start......"

cd ../..
INSTALL_PATH=`pwd`

IK_SRC_PATH=${INSTALL_PATH}"/elasticsearch-ik"

if [ ! -d ${IK_SRC_PATH} ]
then
    echo -e "<WARN> There is no IK install package, install ik cancel."
else
    IK_CONFIG=${IK_SRC_PATH}"/ik"
    if [ ! -d ${IK_CONFIG}  ]
    then
        echo -e "<WARN> Missing ik config file, install ik cancel."
    else
        cp -r ${IK_CONFIG} ${BASE_PATH}"/config/ik"
        if [ ! -f ${IK_SRC_PATH}"/elasticsearch-analysis-ik-1.4.1.jar"  ] || [ ! -f ${IK_SRC_PATH}"/httpclient-4.3.5.jar"  ] || [ ! -f ${IK_SRC_PATH}"/httpcore-4.3.2.jar"  ]
        then
            echo -e "<WARN> Missing ik jar file, install ik cancel."
        else
            cp ${IK_SRC_PATH}"/elasticsearch-analysis-ik-1.4.1.jar" ${BASE_PATH}"/lib"
            cp ${IK_SRC_PATH}"/httpclient-4.3.5.jar" ${BASE_PATH}"/lib"
            cp ${IK_SRC_PATH}"/httpcore-4.3.2.jar" ${BASE_PATH}"/lib"
        fi

    fi
fi

IK_YML="\n\n#IK分词器 \nindex:\n  analysis:\n    analyzer:\n      ik:\n        alias: [ik_analyzer]\n        type: org.elasticsearch.index.analysis.IkAnalyzerProvider"
IK_YML=${IK_YML}"\n      ik_max_word:\n        type: ik\n        use_smart: false\n      ik_smart:\n        type: ik\n        use_smart: true"
IK_YML=${IK_YML}"\nindex.analysis.analyzer.default.type: ik"

echo -e "$IK_YML" >> ${CONFIG_FILE}

echo -e "<INFO> Install IK finish......"


echo -e "\n===========\n<INFO> Install ES in ${ES_NODE_TYPE} mode on node ${ES_LOACL_IP} success.\n=============================\n"
