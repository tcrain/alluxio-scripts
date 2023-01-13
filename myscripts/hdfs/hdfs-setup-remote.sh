#!/bin/bash
set -e

if [ $# -lt 2 ]
then
  echo "command is: hdfs-setup-remote.sh {ip} {install} {key-file} {user}"
  exit
fi

ip=$1
install=$2
keyfile=${3:-~/.ssh/aws-east.pem}
user=${4:-centos}

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

if [ "$install" -ne 0 ]
then
  echo Installing hdfs on "${ip}"
  ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" 'bash -s' < "${scriptDir}"/hdfs-install.sh
else
  echo Starting hdfs on "${ip}"
  ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" 'bash -s' < "${scriptDir}"/hdfs-start.sh
fi