#!/bin/bash
set -e

if [ $# -lt 1 ]
then
  echo "command is: sync-prof.sh {ip} {keyfile} {user}"
  exit 1
fi

ip=$1
keyfile=${2:-~/.ssh/aws-east.pem}
user=${3:-centos}

mkdir -p bench-results

echo Copying over bench results
rsync -ave "ssh -i ${keyfile}" --exclude 'pom.xml' --exclude 'src/*' --exclude 'readme.md' --exclude 'target/*' "${user}"@"${ip}":/home/centos/alluxio/microbench/ ./bench-results/
