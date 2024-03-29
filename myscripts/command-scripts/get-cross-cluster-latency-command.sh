#!/bin/bash
set -e

if [ $# -lt 1 ]
then
  echo "command is: get-cross-cluster-latency-command.sh {clusterIds} {path} {fileCount} {randReaderCount} {syncLatency} {writeType} {masterPort}"
  exit 1
fi

clusterIds=${1:-c1}
path=${2:-/}
fileCount=${3:-100}
randReaderCount=${4:-10}
syncLatency=${5:--1}
writeType=${6:-CACHE_THROUGH}
masterPort=${7:-19998}

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

addrString=""
for clusterId in $clusterIds
do

  IFS=$'\n' read -r -d '' -a masterIps < <( "${scriptDir}"/../aws-ips.sh master PrivateIpAddress "${clusterId}" && printf '\0' )

  # the private ips used as masters
  addrString+=" --ip-list "
  for ip in "${masterIps[@]}"
  do
    addrString+="${ip}:${masterPort},"
  done
  addrString=${addrString%?}
done

echo "~"/alluxio/bin/alluxio runClass alluxio.crosscluster.cli.CrossClusterLatencyMain"${addrString}" --path \""${path}"\" --file-count "${fileCount}" --latency "${syncLatency}" --rand-reader "${randReaderCount}" --write-type "${writeType}"
