#!/bin/bash
set -e

if [ $# -lt 2 ]
then
  echo "command is: alluxio-build.sh {ip} {alluxio-path} {build-alluxio} {build-benches} {key-file} {user}"
  exit
fi

ip=$1
path=$2
buildAlluxio=${3:-0}
buildBenches=${4:-0}
keyfile=${5:-~/.ssh/aws-east.pem}
user=${6:-centos}
hadoopVersion=${7:-3.3.0}
hadoopVersionId=${7:-3}

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

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

cd "${path}"

echo Running rsync: rsync -ave "ssh -i ${keyfile}" --exclude-from="./.gitignore" --exclude='webui' --exclude='stress' --exclude='.git' --exclude='alluxio.tar.gz' . "${user}"@"${ip}":~/alluxio/
rsync -ave "ssh -i ${keyfile}" --exclude-from="./.gitignore" --exclude='webui' --exclude='stress' --exclude='.git' --exclude='alluxio.tar.gz' . "${user}"@"${ip}":~/alluxio/

echo Copying over scripts
rsync -ave "ssh -i ${keyfile}" "${scriptDir}"/ "${user}"@"${ip}":~/alluxio-scripts

echo Copying over alluxio-site.properties from ${scriptDir}
scp -o "StrictHostKeyChecking no" -i "${keyfile}" "${scriptDir}"/alluxio-site.properties "${user}"@"${ip}":~/alluxio/conf/
# cat ~/alluxio-site.properties >> ./conf/alluxio-site.properties

if [ "$buildAlluxio" -ne 0 ]
then
  ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}"  -t "
  cd alluxio
  echo Building: mvn -T 2C clean install -PhdfsActiveSync -Pufs-hadoop-${hadoopVersionId} -Dhadoop.version=${hadoopVersion} -DskipTests -Dmaven.javadoc.skip=true -Dfindbugs.skip=true -Dcheckstyle.skip=true -Dlicense.skip=true
  mvn -T 2C clean install -PhdfsActiveSync -Pufs-hadoop-${hadoopVersionId} -Dhadoop.version=${hadoopVersion} -DskipTests -Dmaven.javadoc.skip=true -Dfindbugs.skip=true -Dcheckstyle.skip=true -Dlicense.skip=true
  "
fi

if [ "$buildBenches" -ne 0 ]
then
    ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}"  -t "
    cd alluxio
    mvn clean install -pl jmh -DskipTests -Dmaven.javadoc.skip=true -Dfindbugs.skip=true -Dcheckstyle.skip=true -Dlicense.skip=true
    "
fi
