#!/bin/bash
set -e

if [ "$#" -ne 1 ]
then
  echo "command is: s3-install.sh {ip}"
  exit
fi

ip=$1
bucketName=${2:-alluxiotyler}
s3Config=${3:-~/.aws/config}
s3Credentials=${4:-~/.aws/credentials}
keyfile=${5:-~/.ssh/aws-east.pem}
user=${6:-centos}

# copy over s3 credentials
ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" "
  mkdir -p ~/.aws
"
scp -o "StrictHostKeyChecking no" -i "${keyfile}" "${s3Credentials}" "${user}"@"${ip}":~/.aws/credentials
scp -o "StrictHostKeyChecking no" -i "${keyfile}" "${s3Config}" "${user}"@"${ip}":~/.aws/config

ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" -t "
  curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
  unzip awscliv2.zip
  sudo ./aws/install
  rm awscliv2.zip
  rm -rf ./aws
  aws --version

  cd ~/alluxio
  bin/alluxio runUfsTests --path s3://${bucketName} --test listStatusTest
"

# echo \"alluxio.master.mount.table.root.ufs=s3://${bucketName}\" >> ~/alluxio/conf/alluxio-site.properties

