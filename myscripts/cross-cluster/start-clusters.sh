#!/bin/bash
set -e

if [ $# -gt 5 ]
then
  echo "command is: start-clusters.sh {clusterIds} {crossClusterStandalone} {format} {create-mounts} {key-file} {user}"
  exit
fi

clusterIds=${1:-c1}
crossClusterStandalone=${2:-1}
format=${3:-0}
createMounts=${4:-0}
keyfile=${5:-~/.ssh/aws-east.pem}
user=${6:-centos}

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

echo "Restarting hdfs"
"${scriptDir}"/../run-command-cluster.sh "${clusterIds}" "~/alluxio-scripts/hdfs/hdfs-start.sh" hdfs 0 "${keyfile}" "${user}"

echo "Stopping alluxio"
"${scriptDir}"/../run-command-cluster.sh "${clusterIds}" "~/alluxio/bin/alluxio-stop.sh all" master 0 "${keyfile}" "${user}"

if [ "$format" -ne 0 ]
then
"${scriptDir}"/../run-command-cluster.sh "${clusterIds}" "~/alluxio/bin/alluxio format" master 0 "${keyfile}" "${user}"
fi

if [ "$crossClusterStandalone" -ne 0 ]
then
  for clusterId in $clusterIds
  do
    echo "Starting cross cluster standalone"
    "${scriptDir}"/../run-command-cluster.sh "${clusterId}" "~/alluxio/bin/alluxio-start.sh cross_cluster_master" master 0 "${keyfile}" "${user}"
    break
  done
fi

echo "Starting alluxio"
"${scriptDir}"/../run-command-cluster.sh "${clusterIds}" "~/alluxio/bin/alluxio-start.sh all SudoMount" master 0 "${keyfile}" "${user}"

if [ "$createMounts" -ne 0 ]
then

  echo "Creating s3 mounts"
  "${scriptDir}"/../run-command-cluster.sh "${clusterIds}" "~/alluxio/bin/alluxio fs mkdir /mnt; ~/alluxio/bin/alluxio fs mount --crosscluster /mnt/s3crosscluster s3://alluxiotyler; ~/alluxio/bin/alluxio fs mount /mnt/s3timesync s3://alluxiotyler2" master 0 "${keyfile}" "${user}"

  hdfsIp=$("${scriptDir}"/../aws-ips.sh hdfs PrivateIpAddress "$(echo "${clusterIds}" | cut -d ' ' -f1)" | head -n 1)

  if [ "$hdfsIp" != "" ]
  then
    echo "Creating hdfs mounts"
    "${scriptDir}"/../run-command-cluster.sh "${clusterIds}" "~/alluxio/bin/alluxio fs mount --crosscluster /mnt/hdfscrosscluster hdfs://${hdfsIp}:9000/crosscluster; ~/alluxio/bin/alluxio fs mount /mnt/hdfstimesync hdfs://${hdfsIp}:9000/timesync" master 0 "${keyfile}" "${user}"
  fi

fi