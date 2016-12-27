#!/bin/bash
#***********************************************************  
# Title: elasticsearch集群部署脚本
# 请确保各ES节点机器的配置、系统的配置、java、scala、无密码ssh、rsync等依赖基础环境保持一致
# Parameters:  
#   INSTALL_PATH     - ES部署目录
#   ES_VERSION       - ES的版本号（1.7.3和1.7.4版本从本地拷贝，高版本自动下载）
#   CLUSTER_NAME     - ES集群名称
#   USER             - ES部署机器用户
#   HTTP_PORT        - ES集群HTTP端口号
#   MASTER_NODES     - ES集群MASTER节点列表 用逗号分开（10.1.1.1,10.2.2.2,10.3.3.3）
#   DATA_NODES       - ES集群DATA节点列表 用逗号分开（10.1.1.1,10.2.2.2,10.3.3.3）
# Example:  
#   1) /bin/bash es-cluster-deploy.sh /opt/mouse/search 1.7.3 xm-search mouse 8412 192.168.0.2 192.168.0.3,192.168.0.4
#***********************************************************  

#==============================
#1. 预处理：解析安装脚本参数
#==============================

if [ $# -lt 7  ];
then
    echo -e "\033[31m<WARN> USAGE:\n    /bin/bash es-cluster-deploy.sh <INSTALL_PTAH> <ES_VERSION> <CLUSTER_NAME>\033[0m"
    echo -e "\033[31m                                                  <USER> <HTTP_PORT> <MASTER_NODES> <DATA_NODES>\033[0m"
    exit 1
fi

if [ ! -n ${INSTALL_PATH}  ] || [ ! -n ${ES_VERSION}  ] || [ ! -n ${USER}  ] || [ ! -n ${MASTER_NODES}  ] || [ ! -n ${DATA_NODES}  ] || [ ! -n ${CLUSTER_NAME}  ] || [ ! -n ${HTTP_PORT}  ]
then
    echo -e "\033[31m<INFO> Params can not benull, please check!\033[0m]]"
fi

INSTALL_PATH=$1
ES_VERSION=$2
CLUSTER_NAME=$3
USER=$4
HTTP_PORT=$5
MASTER_NODES=$6
DATA_NODES=$7

#判断是从本地拷贝还是远程下载
if [ ${ES_VERSION}"x" = "1.7.3x"  ] || [ ${ES_VERSION}"x" = "1.7.4x"  ]
then
    COPY_TYPE="LOCAL"
else
    COPY_TYPE="REMOTE"
fi

#==============================
#2. 解析各节点类型
#==============================
M_LIST=${MASTER_NODES//,/ }
D_LIST=${DATA_NODES//,/ }
DM_LIST=""

for ele_m in ${M_LIST}
do
    for ele_d in ${D_LIST}
    do
        if [ ${ele_d}"x" = ${ele_m}"x" ] 
        then
            if [ "${DM_LIST}'x'" = "x" ]
            then
                DM_LIST=${ele_m}
            else
                DM_LIST=${DM_LIST}" "${ele_m}
            fi
        fi
    done
done

for ele in ${DM_LIST}
do
    M_LIST=`echo "${M_LIST}" | sed "s/${ele}//g"`
    D_LIST=`echo "${D_LIST}" | sed "s/${ele}//g"`
done

M_LIST=`echo ${M_LIST}`
D_LIST=`echo ${D_LIST}`
DM_LIST=`echo ${DM_LIST}`

TOTAL_LIST=""

for ele in ${M_LIST}
do 
    if [ "${TOTAL_LIST}'x'" = "x" ]
    then
        TOTAL_LIST=${ele}
    else
        TOTAL_LIST=${TOTAL_LIST}","${ele}
    fi
done

for ele in ${D_LIST}
do 
    if [ "${TOTAL_LIST}'x'" = "x" ]
    then
        TOTAL_LIST=${ele}
    else
        TOTAL_LIST=${TOTAL_LIST}","${ele}
    fi
done

for ele in ${DM_LIST}
do 
    if [ "${TOTAL_LIST}'x'" = "x" ]
    then
        TOTAL_LIST=${ele}
    else
        TOTAL_LIST=${TOTAL_LIST}","${ele}
    fi
done

TOTAL_LIST=`echo ${TOTAL_LIST}`



echo -e "<INFO> Master node list : ${M_LIST}"
echo -e "<INFO> Data node list   : ${D_LIST}"
echo -e "<INFO> MD node list     : ${DM_LIST}"
echo -e "<INFO> Total node list  : ${TOTAL_LIST}"



#==============================
#3. 针对各类型节点安装ES
#==============================
ES_NODE_NUM=0

for ele in ${M_LIST}
do
    if [ "${ele}'x'" != "x"  ]
    then
        ES_NODE_NUM=$[$ES_NODE_NUM+1]
        echo -e "<INFO> Install elasticsearch in master mode on ${USER}@${ele}"
        if [ ${COPY_TYPE} = "LOCAL" ]
        then
            rsync -rptog "elasticsearch-"${ES_VERSION}".tar.gz" ${ele}:${INSTALL_PATH}
        fi

        rsync -rptog "elasticsearch-ik" ${ele}:${INSTALL_PATH}
        rsync -rptog "es-install.sh" ${ele}:${INSTALL_PATH}

        ssh ${USER}@${ele} "cd $INSTALL_PATH && /bin/bash es-install.sh . ${ES_NODE_NUM} ${ele} ${TOTAL_LIST} ${CLUSTER_NAME} ${HTTP_PORT} MASTER ${ES_VERSION}"
        ssh ${USER}@${ele} "cd $INSTALL_PATH && rm -rf elasticsearch-ik"
        ssh ${USER}@${ele} "cd $INSTALL_PATH && rm -rf es-install.sh"
        ssh ${USER}@${ele} "cd $INSTALL_PATH && rm -rf 'elasticsearch-'${ES_VERSION}'.tar.gz'"
        # TO BE CONTINUE
        #
        #
    fi
done

for ele in ${D_LIST}
do
    if [ "${ele}'x'" != "x"  ]
    then
        ES_NODE_NUM=$[$ES_NODE_NUM+1]
        echo -e "<INFO> Install elasticsearch in data mode on ${USER}@${ele}"
        if [ ${COPY_TYPE} = "LOCAL" ]
        then
            rsync -rptog "elasticsearch-"${ES_VERSION}".tar.gz" ${ele}:${INSTALL_PATH}
        fi

        rsync -rptog "elasticsearch-ik" ${ele}:${INSTALL_PATH}
        rsync -rptog "es-install.sh" ${ele}:${INSTALL_PATH}

        ssh ${USER}@${ele} "cd $INSTALL_PATH && /bin/bash es-install.sh . ${ES_NODE_NUM} ${ele} ${TOTAL_LIST} ${CLUSTER_NAME} ${HTTP_PORT} DATA ${ES_VERSION}" 
        ssh ${USER}@${ele} "cd $INSTALL_PATH && rm -rf elasticsearch-ik"
        ssh ${USER}@${ele} "cd $INSTALL_PATH && rm -rf es-install.sh"
        ssh ${USER}@${ele} "cd $INSTALL_PATH && rm -rf 'elasticsearch-'${ES_VERSION}'.tar.gz'"
        # TO BE CONTINUE
        #
        #
    fi
done

for ele in ${DM_LIST}
do
    if [ "${ele}'x'" != "x"  ]
    then
        ES_NODE_NUM=$[$ES_NODE_NUM+1]
        echo -e "<INFO> Install elasticsearch in mix mode on ${USER}@${ele}"
        if [ ${COPY_TYPE} = "LOCAL" ]
        then
            rsync -rptog "elasticsearch-"${ES_VERSION}".tar.gz" ${ele}:${INSTALL_PATH}
        fi

        rsync -rptog "elasticsearch-ik" ${ele}:${INSTALL_PATH}
        rsync -rptog "es-install.sh" ${ele}:${INSTALL_PATH}

        ssh ${USER}@${ele} "cd $INSTALL_PATH && /bin/bash es-install.sh . ${ES_NODE_NUM} ${ele} ${TOTAL_LIST} ${CLUSTER_NAME} ${HTTP_PORT} DM ${ES_VERSION}" 
        ssh ${USER}@${ele} "cd $INSTALL_PATH && rm -rf elasticsearch-ik"
        ssh ${USER}@${ele} "cd $INSTALL_PATH && rm -rf es-install.sh"
        ssh ${USER}@${ele} "cd $INSTALL_PATH && rm -rf 'elasticsearch-'${ES_VERSION}'.tar.gz'"
        # TO BE CONTINUE
        #
        #
    fi
done


echo -e "\n\n\n**********************************************\n<INFO> ES cluster deploy finished!\n**********************************************\n"

