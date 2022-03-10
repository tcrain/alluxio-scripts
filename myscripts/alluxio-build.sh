#!/bin/bash
set -e

if [ $# -lt 2 ]
then
  echo "command is: attach-stats.sh {ip} {alluxio-path} {key-file} {user}"
  exit
fi

ip=$1
path=$2
keyfile=${3:-~/.ssh/aws-east.pem}
user=${4:-centos}

ssh -o "StrictHostKeyChecking no" -i ${keyfile} ${user}@${ip}  -t "
  cd alluxio
  # format journal and worker
  ./bin/alluxio-stop.sh all
  fusermount -u ../fuseIOBench
  fusermount -u -z ../fuseIOBench

  rm -rf ~/fuseIOBench
  ./bin/alluxio format
  rm -rf ~/alluxio/underFSStorage
  mkdir -p ~/alluxio/underFSStorage
"

echo Running rsync: rsync -ave "ssh -i ${keyfile}" --exclude-from="${path}/.gitignore" --exclude='webui' --exclude='stress' --exclude='.git' --exclude='alluxio.tar.gz' ${path} ${user}@${ip}:~/alluxio/
rsync -ave "ssh -i ${keyfile}" --exclude-from="${path}/.gitignore" --exclude='webui' --exclude='stress' --exclude='.git' --exclude='alluxio.tar.gz' ${path} ${user}@${ip}:~/alluxio/

ssh -o "StrictHostKeyChecking no" -i ${keyfile} ${user}@${ip}  -t "
cd alluxio
mvn -T 2C clean install -DskipTests -Dmaven.javadoc.skip=true -Dfindbugs.skip=true -Dcheckstyle.skip=true -Dlicense.skip=true
"
