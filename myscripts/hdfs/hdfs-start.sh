#!/bin/bash
set -e

if [ "$#" -gt 1 ]
then
  echo "command is: hdfs-start.sh {format}"
  exit 1
fi

format=${1:-1}

echo Stopping hdfs
~/hadoop/sbin/stop-dfs.sh

if [ "${format}" -ne 0 ]
then
  # format hdfs
  echo Formatting hdfs
  ~/hadoop/bin/hdfs namenode -format -force
fi

# start hdfs
echo Starting hdfs
~/hadoop/sbin/start-dfs.sh

echo Checking if can write dir in hdfs
# make a home dir in hdfs
~/hadoop/bin/hdfs dfs -mkdir -p /user/centos

~/hadoop/bin/hdfs dfs -mkdir -p /crosscluster
~/hadoop/bin/hdfs dfs -mkdir -p /timesync

~/hadoop/bin/hdfs dfs -ls -R
