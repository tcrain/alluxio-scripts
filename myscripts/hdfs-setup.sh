#!/bin/bash
set -e

if [ "$#" -lt 3 ]
then
  echo "command is: hdfs-setup.sh {enable-profile} {enable-debug} {run-type} {mount-path} {enable-active-sync}"
  echo "0 = disable profile, debug 1 = enable"
  echo "run-type: 0 = install, 1 = initial setup"
  exit 1
fi

profile=$1
debug=$2
runType=$3
hdfsAddress=${4:-hdfs://localhost:9000}
mountPath=${5:-/hdfs}
enableActiveSync=${6:-1}

if [ "$runType" -eq 0 ]
then

  hadoopVersion=3.3.2
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

elif [ "$runType" -eq 1 ]
then

  # echo "alluxio.master.mount.table.root.ufs=hdfs://localhost:9000" >> ~/alluxio/conf/alluxio-site.properties
  echo "alluxio.master.ufs.active.sync.interval=30s" >> ~/alluxio/conf/alluxio-site.properties

  # format journal and worker
  ~/alluxio/bin/alluxio-stop.sh all
  ~/alluxio/bin/alluxio format

  ~/hadoop/sbin/stop-dfs.sh
  # format hdfs
  ~/hadoop/bin/hdfs namenode -format -force
  # start hdfs
  ~/hadoop/sbin/start-dfs.sh
  # make a home dir in hdfs
  ~/hadoop/bin/hdfs dfs -mkdir -p /user/centos
  ~/hadoop/bin/hdfs dfs -ls -R

  # start alluxio
  ~/alluxio-scripts/alluxio-start.sh "$profile" "$debug"

  # mount hdfs
  ~/alluxio/bin/alluxio fs mount "${mountPath}" "${hdfsAddress}"

  # be sure we can read it in alluxio
  listing=$(~/alluxio/bin/alluxio fs ls -R -Dalluxio.user.file.metadata.sync.interval=0 /)
  echo "$listing"
  if [ "$(echo "$listing" | wc -l)" -lt 1 ]
  then
    echo "Empty listing of alluxio file system"
    exit 1
  fi

  if [ "$enableActiveSync" -eq 1 ]
  then
    echo "Enabling active sync"
    ~/alluxio/bin/alluxio fs startSync "${mountPath}"
    ~/alluxio/bin/alluxio fs getSyncPathList
  fi

fi