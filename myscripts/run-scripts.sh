#!/bin/bash
set -e

if [ $# -lt 2 ]
then
  echo "command is: run-script.sh {ip} {alluixo-path} {key-file} {user}"
  exit
fi

ip=$1
path=$2
keyfile=${3:-~/.ssh/aws-east.pem}
user=${4:-centos}

# copy over the key file
scp -o "StrictHostKeyChecking no" -i ${keyfile} ${keyfile} ${user}@${ip}:~/.ssh/id_rsa

scp -o "StrictHostKeyChecking no" -i ${keyfile} alluxio-site.properties ${user}@${ip}:~/

# do the initial setup
ssh -o "StrictHostKeyChecking no" -i ${keyfile} ${user}@${ip} 'bash -s' < ./initialsetup.sh

# install perf stuff
ssh -o "StrictHostKeyChecking no" -i ${keyfile} ${user}@${ip} 'bash -s' < ./perf.sh

# copy fuse setup script
scp -o "StrictHostKeyChecking no" -i ${keyfile} ./fuse-setup.sh ${user}@${ip}:~/

# build alluxio
cd ${path}
./myscripts/alluxio-build.sh "$ip" . "$keyfile" "$user"

ssh -o "StrictHostKeyChecking no" -i ${keyfile} ${user}@${ip} "
  cd alluxio
  ./bin/alluxio format
  ./bin/alluxio-start.sh local SudoMount
  ./bin/alluxio runTests
  ./bin/alluxio-stop.sh local
"