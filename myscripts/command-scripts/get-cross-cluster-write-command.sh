#!/bin/bash
set -e

if [ $# -lt 1 ]
then
  echo "command is: get-cross-cluster-write-command.sh {clusterIds} {path} {duration} {writeThreads} {filesPerDir} {rateLimit} {syncLatency} {singleWriter} {writeType} {masterPort}"
  exit 1
fi

clusterIds=${1:-c1}
path=${2:-/}
duration=${3:-10000}
writeThreads=${4:-10}
filesPerDir=${5:-1000}
rateLimit=${6:-0}
syncLatency=${7:--1}
singleWriter=${8:-0}
writeType=${9:-CACHE_THROUGH}
masterPort=${10:-19998}

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

if [ "$singleWriter" -ne 0 ]
then
  doSingleWriter="--single-writer-cluster"
fi

echo "~"/alluxio/bin/alluxio runClass alluxio.crosscluster.cli.CrossClusterWriteMain"${addrString}" --path \""${path}"\" --duration "${duration}" --write-threads "${writeThreads}" --rate-limit "${rateLimit}" --latency "${syncLatency}" "${doSingleWriter}" --folder-size "${filesPerDir}" --write-type "${writeType}"
