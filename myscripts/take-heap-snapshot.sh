#!/bin/bash
set -e

if [ $# -lt 1 ]
then
  echo "command is: attach-stats.sh {ip} {key-file} {user}"
  exit 1
fi

ip=$1
keyfile=${2:-~/.ssh/aws-east.pem}
user=${3:-centos}

time=$(date '+%s')

ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}"  -t "
  echo Running: jmap -dump:format=b,file=snapshot-${time}-${ip} \$(jps | grep AlluxioMaster | awk '{print \$1}')
  jmap -dump:format=b,file=snapshot-${time}-${ip} \$(jps | grep AlluxioMaster | awk '{print \$1}')
"

scp -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}":~/snapshot-"${time}"-"${ip}" ./
