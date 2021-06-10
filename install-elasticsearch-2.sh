#!/bin/bash
yum remove elasticsearch -y
wget -P /usr/local/src https://static0.xesimg.com/elkpackage/elasticsearch-6.4.0.rpm
yum localinstall /usr/local/src/elasticsearch-6.4.0.rpm -y
local_ip=$(ifconfig | grep '\<inet\>'| grep -v '127.0.0.1' | awk '{ print $2}' | awk 'NR==1')
result=$(echo $local_ip | grep ":")
if [[ "$result" != "" ]];then
    local_ip=${local_ip#*:}
    echo $local_ip
else
    echo $local_ip
fi

#判断jdk是否安装。
avalabejava=`whereis java| awk '{ print $2}'`
if [[ $avalabejava =~ java ]];then
    echo "$avalabejava include java"
else
    wget -P /usr/local/src https://static0.xesimg.com/elkpackage/shell/install-jjdk.sh
    /usr/bin/bash   /usr/local/src/install-jjdk.sh
    source /etc/profile
fi

master1=${local_ip}:9500
loghome=/home/logs/elasticsearch
data_home=/elasticsearch/data
snapshort_home=/elasticsearch/snapshort-back
cat << EOF > /etc/elasticsearch/elasticsearch.yml
cluster.name: elasticsearch-study
node.name: \${HOSTNAME}-test
path.data: ${data_home}
path.logs: ${loghome}
bootstrap.memory_lock: true
network.host: 0.0.0.0
http.port: 9400
discovery.zen.ping.unicast.hosts: ["${master1}"]
discovery.zen.minimum_master_nodes: 1
transport.tcp.port: 9500
node.master: false
node.data: false
http.cors.enabled: true
http.cors.allow-origin: "*"
node.attr.zone: client
discovery.zen.fd.ping_interval: 60s
discovery.zen.fd.ping_timeout: 10s
discovery.zen.fd.ping_retries: 5
indices.fielddata.cache.size: 20%
indices.memory.index_buffer_size: 20%
indices.memory.min_index_buffer_size: 96mb
path.repo: ["${snapshort_home}"]
script.painless.regex.enabled: true
script.max_compilations_rate: 150/5m
thread_pool.index.queue_size: 1000
thread_pool.write.queue_size: 1000
thread_pool.bulk.queue_size: 1000
reindex.remote.whitelist: "*:9200"
EOF
mkdir -p ${snapshort_home}
mkdir -p ${data_home}
mkdir -p ${loghome}
chown -R elasticsearch:elasticsearch ${loghome}
chown -R elasticsearch:elasticsearch ${data_home}
chown -R elasticsearch:elasticsearch ${snapshort_home}
chown -R elasticsearch:elasticsearch /elasticsearch
cat << EOF >> /etc/security/limits.conf
elasticsearch soft memlock unlimited
elasticsearch hard memlock unlimited
EOF
cat << EOF >> /etc/sysctl.conf
vm.swappiness = 0
vm.max_map_count=262144
EOF
#避免jps命令看不到Elasticsearch进程
cat << EOF >>  /usr/lib/tmpfiles.d/tmp.conf
x /tmp/hsperfdata_elasticsearch
x /tmp/hsperfdata_elasticsearch*
x /tmp/hsperfdata_elasticsearch_*
x /tmp/hsperfdata_elasticsearch-*
EOF

#获取当前机器的CPU和剩余内存
cpu=`cat /proc/cpuinfo | grep "processor" | sort | uniq | wc -l`
avalabeMem=`free -h|grep "Mem"|awk '{ print $7}'`
catunits=(g G m M)
canuseMem=`free -h|grep "Mem"|awk '{ print $7}'|tr -cd "[0-9]"`
unit='m'
for catunit in ${catunits[@]};
do
  if [[ $avalabeMem =~ ${catunit} ]]
  then
    echo "$avalabeMem include ${catunit}"
    unit=${catunit}
  fi
done
unit=`echo ${unit}|tr '[A-Z]' '[a-z]'`
worker=$((${cpu}*2))
#取机器内存的一半，如果大于32GB则，jvm堆内存取30GB
jvmheap=$((${canuseMem}/2))
if [ "$unit" == "g" ] && (( $jvmheap > 32 )) ;then
  jvmheap=30
fi
echo "cpu-worker="$worker
echo "jvmheap="$jvmheap$unit

heap=$jvmheap$unit


cat << EOF >/etc/elasticsearch/jvm.options
-Xms${heap}
-Xmx${heap}
-XX:+UseG1GC
-XX:MaxGCPauseMillis=100
-XX:GCPauseIntervalMillis=1000
-XX:InitiatingHeapOccupancyPercent=35
## optimizations
# pre-touch memory pages used by the JVM during initialization
-XX:+AlwaysPreTouch
-Xss1m
-Djava.awt.headless=true
-Dfile.encoding=UTF-8
# use our provided JNA always versus the system one
-Djna.nosys=true
# turn off a JDK optimization that throws away stack traces for common
# exceptions because stack traces are important for debugging
-XX:-OmitStackTraceInFastThrow
# flags to configure Netty
-Dio.netty.noUnsafe=true
-Dio.netty.noKeySetOptimization=true
-Dio.netty.recycler.maxCapacityPerThread=0
# log4j 2
-Dlog4j.shutdownHookEnabled=false
-Dlog4j2.disable.jmx=true
-Djava.io.tmpdir=\${ES_TMPDIR}
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=${loghome}
-XX:ErrorFile=${loghome}/hs_err_pid%p.log
## JDK 8 GC logging
8:-XX:+PrintGCDetails
8:-XX:+PrintGCDateStamps
8:-XX:+PrintTenuringDistribution
8:-XX:+PrintGCApplicationStoppedTime
8:-Xloggc:${loghome}/gc.log
8:-XX:+UseGCLogFileRotation
8:-XX:NumberOfGCLogFiles=32
8:-XX:GCLogFileSize=64m
# JDK 9+ GC logging
9-:-Xlog:gc*,gc+age=trace,safepoint:file=${loghome}/gc.log:utctime,pid,tags:filecount=32,filesize=64m
# due to internationalization enhancements in JDK 9 Elasticsearch need to set the provider to COMPAT otherwise
# time/date parsing will break in an incompatible way for some date patterns and locals
9-:-Djava.locale.providers=COMPAT
# temporary workaround for C2 bug with JDK 10 on hardware with AVX-512
10-:-XX:UseAVX=2
EOF
cat << EOF >/usr/lib/systemd/system/elasticsearch.service
[Unit]
Description=Elasticsearch
Documentation=http://www.elastic.co
Wants=network-online.target
After=network-online.target

[Service]
RuntimeDirectory=elasticsearch
PrivateTmp=false
Environment=ES_HOME=/usr/share/elasticsearch
Environment=ES_PATH_CONF=/etc/elasticsearch
Environment=PID_DIR=/var/run/elasticsearch
EnvironmentFile=-/etc/sysconfig/elasticsearch

WorkingDirectory=/usr/share/elasticsearch

User=elasticsearch
Group=elasticsearch

ExecStart=/usr/share/elasticsearch/bin/elasticsearch -p \${PID_DIR}/elasticsearch.pid --quiet

# StandardOutput is configured to redirect to journalctl since
# some error messages may be logged in standard output before
# elasticsearch logging system is initialized. Elasticsearch
# stores its logs in /var/log/elasticsearch and does not use
# journalctl by default. If you also want to enable journalctl
# logging, you can simply remove the "quiet" option from ExecStart.
StandardOutput=journal
StandardError=inherit

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of processes
LimitNPROC=4096

# Specifies the maximum size of virtual memory
LimitAS=infinity

# Specifies the maximum file size
LimitFSIZE=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=0

# SIGTERM signal is used to stop the Java process
KillSignal=SIGTERM

# Send the signal only to the JVM rather than its control group
KillMode=process

# Java process is never killed
SendSIGKILL=no
LimitMEMLOCK=infinity
Type=simple
Restart=always
RestartSec=5
StartLimitInterval=0
RestartPreventExitStatus=SIGTERM
# When a JVM receives a SIGTERM signal it exits with code 143
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target

# Built for packages-6.4.0 (packages)
EOF
sysctl -w vm.max_map_count=262144
sysctl -p
swapoff -a
chown -R elasticsearch:elasticsearch /var/lib/elasticsearch
chown -R elasticsearch:elasticsearch /var/log/elasticsearch
systemctl enable elasticsearch
systemctl start elasticsearch
# 如果启动不成功查看日志,如果日志目录下查看不到日志，则可以使用以下命令查看日志
# journalctl --unit elasticsearch --since "2021-05-31 18:00:00"
