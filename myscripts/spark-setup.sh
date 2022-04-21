#!/bin/bash
set -e

if [ "$#" -ne 1 ]
then
  echo "command is: sparkSetup.sh {run-type}"
  echo "run-type is: 0 - install, 1 - test if working"
  exit
fi

runType=$1

if [ "$runType" -eq 0 ]
then

  sparkHadoopVersion=3.2
  sparkVersion=3.2.1

  sparkName=spark-${sparkVersion}-bin-hadoop${sparkHadoopVersion}

  wget https://dlcdn.apache.org/spark/spark-${sparkVersion}/${sparkName}.tgz
  tar xzf ${sparkName}.tgz
  rm ${sparkName}.tgz
  mv ${sparkName} ~/spark

  echo "
spark.driver.extraJavaOptions -Dalluxio.master.rpc.addresses=localhost:19998
spark.executor.extraJavaOptions -Dalluxio.master.rpc.addresses=localhost:19998
spark.driver.extraClassPath   /home/centos/alluxio/client/alluxio-2.8.0-SNAPSHOT-client.jar
spark.executor.extraClassPath /home/centos/alluxio/client/alluxio-2.8.0-SNAPSHOT-client.jar
" >> ~/spark/conf/spark-defaults.conf

elif [ "$runType" -eq 1 ]
then

  echo Stopping spark cluster
  ~/spark/sbin/stop-all.sh

  echo Testing spark shell
  ts=$(date +%s%N)
  ~/alluxio/bin/alluxio fs copyFromLocal ~/alluxio-scripts/wcInput /wcInput"${ts}"
  ~/alluxio/bin/alluxio fs copyFromLocal ~/alluxio/LICENSE /Input"${ts}"
  echo "
  val s = sc.textFile(\"alluxio:///Input${ts}\")
  val double = s.map(line => line + line)
  double.saveAsTextFile(\"alluxio:///Output${ts}\")
  " | ~/spark/bin/spark-shell --master local[2]

  ~/alluxio/bin/alluxio fs ls /Output"${ts}"/_SUCCESS

   echo Starting spark cluster
   ~/spark/sbin/start-master.sh -h localhost
   ~/spark/sbin/start-worker.sh -h localhost spark://localhost:7077

   echo Running spark test job
   ~/spark/bin/spark-submit --class "org.apache.spark.examples.JavaWordCount" --master spark://localhost:7077 ~/spark/examples/jars/spark-examples*.jar alluxio:///wcInput"${ts}" 2> sparkjob.out

fi