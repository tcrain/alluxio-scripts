#!/bin/bash
set -e

if [ $# -lt 2 ]
then
  echo "command is: alluxio-build.sh {ip} {alluxio-path} {build-alluxio} {build-benches} {format} {key-file} {user}"
  exit 1
fi

ip=$1
path=$2
buildAlluxio=${3:-0}
buildBenches=${4:-0}
format=${5:-0}
keyfile=${6:-~/.ssh/aws-east.pem}
user=${7:-centos}
hadoopVersion=${8:-3.3.0}
hadoopVersionId=${9:-3}

siteProperties="alluxio-site.properties.cluster"
alluxioEnv="alluxio-env.sh.cluster"

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

if [ "$format" -ne 0 ]
then
  ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}"  -t "
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
fi

cd "${path}"

echo Running rsync: rsync -ave "ssh -i ${keyfile}" --exclude-from="./.gitignore" --exclude 'webui' --exclude='.git' --exclude 'conf/masters' --exclude 'logs*' --exclude='alluxio.tar.gz' . "${user}"@"${ip}":~/alluxio/
rsync -ave "ssh -i ${keyfile}" --exclude-from="./.gitignore" --exclude 'webui' --exclude='.git' --exclude 'conf/masters' --exclude 'logs*' --exclude='alluxio.tar.gz' . "${user}"@"${ip}":~/alluxio/

echo Copying over scripts
rsync -ave "ssh -i ${keyfile}" --exclude 'logs*' --exclude 'node-logs*' --exclude 'bench-results/*' --exclude='snapshot-*' "${scriptDir}"/ "${user}"@"${ip}":~/alluxio-scripts

echo Copying over alluxio-site.properties from "${scriptDir}"/${siteProperties}
scp -o "StrictHostKeyChecking no" -i "${keyfile}" "${scriptDir}"/${siteProperties} "${user}"@"${ip}":~/alluxio/conf/alluxio-site.properties

echo Copying over alluxio-env.sh from "${scriptDir}"/${alluxioEnv}
scp -o "StrictHostKeyChecking no" -i "${keyfile}" "${scriptDir}"/${alluxioEnv} "${user}"@"${ip}":~/alluxio/conf/alluxio-env.sh

if [ "$buildAlluxio" -ne 0 ]
then
  ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}"  -t "
  cd alluxio
  echo Building: mvn -U -T 2C clean install -PhdfsActiveSync -Pufs-hadoop-${hadoopVersionId} -Dhadoop.version=${hadoopVersion} -DskipTests -Dmaven.javadoc.skip=true -Dfindbugs.skip=true -Dcheckstyle.skip=true -Dlicense.skip=true
  mvn -T 2C clean install -PhdfsActiveSync -Pufs-hadoop-${hadoopVersionId} -Dhadoop.version=${hadoopVersion} -DskipTests -Dmaven.javadoc.skip=true -Dfindbugs.skip=true -Dcheckstyle.skip=true -Dlicense.skip=true
  "
fi

if [ "$buildBenches" -ne 0 ]
then
    ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}"  -t "
    cd alluxio
    mvn -DskipTests package -pl microbench -Dcheckstyle.skip=true -Dlicense.skip=true -Dfindbugs.skip=true
    "
fi
