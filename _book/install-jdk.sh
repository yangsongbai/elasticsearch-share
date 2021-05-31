#!/bin/bash
wget -P /usr/local/src  https://static0.xesimg.com/elkpackage/jdk-8u261-linux-x64.tar.gz
tar -zxf /usr/local/src/jdk-8u261-linux-x64.tar.gz
mkdir -p /usr/java
mv  jdk1.8.0_261 /usr/java/
cat << EOF >> /etc/profile
#java environment
export JAVA_HOME=/usr/java/jdk1.8.0_261
export CLASSPATH=.:\${JAVA_HOME}/jre/lib/rt.jar:\${JAVA_HOME}/lib/dt.jar:\${JAVA_HOME}/lib/tools.jar
export PATH=\$PATH:\${JAVA_HOME}/bin
EOF
source /etc/profile
ln -s /usr/java/jdk1.8.0_261/bin/java  /usr/bin/java