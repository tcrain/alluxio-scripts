#!/bin/bash
set -e

if [ $# -lt 1 ]
then
  echo "command is: copy-alluxio-jar.sh {alluxio-path} {key-file} {user}"
  exit
fi

alluxioPath="${1}"
keyfile=${2:-~/.ssh/aws-east.pem}
user=${3:-centos}

ips=$(aws ec2 describe-instances --no-cli-pager --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text | sed  '/None/d')

for ip in $ips
do
  echo Running: rsync -ave "ssh -i ${keyfile}" -z "${alluxioPath}"/assembly/server/target "${user}"@"${ip}":~/alluxio/assembly/server/
  rsync -ave "ssh -i ${keyfile}" -z "${alluxioPath}"/assembly/server/target "${user}"@"${ip}":~/alluxio/assembly/server/

  echo Running: rsync -ave "ssh -i ${keyfile}" -z "${alluxioPath}"/assembly/client/target "${user}"@"${ip}":~/alluxio/assembly/client/
  rsync -ave "ssh -i ${keyfile}" -z "${alluxioPath}"/assembly/client/target "${user}"@"${ip}":~/alluxio/assembly/client/

  echo Running: rsync -ave "ssh -i ${keyfile}" -z "${alluxioPath}"/lib "${user}"@"${ip}":~/alluxio/
  rsync -ave "ssh -i ${keyfile}" -z "${alluxioPath}"/lib "${user}"@"${ip}":~/alluxio/
done