#!/bin/bash
set -e

if [ "$#" -ne 0 ]
then
  echo "command is: hdfs-install.sh"
  exit 1
fi

hadoopVersion=3.3.2

cd ~/
rm -rf ~/hadoop
wget https://dlcdn.apache.org/hadoop/common/hadoop-${hadoopVersion}/hadoop-${hadoopVersion}.tar.gz
tar xzf hadoop-${hadoopVersion}.tar.gz
rm hadoop-${hadoopVersion}.tar.gz
mv hadoop-${hadoopVersion} ~/hadoop
cd ~/hadoop

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
    <configuration>
        <property>
            <name>fs.defaultFS</name>
            <value>hdfs://localhost:9000</value>
        </property>
    </configuration>
    " > ./etc/hadoop/core-site.xml

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
    <configuration>
        <property>
            <name>dfs.replication</name>
            <value>1</value>
        </property>
    </configuration>
    " > ./etc/hadoop/hdfs-site.xml

echo Done installing hdfs