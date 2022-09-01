#!/bin/bash
set -e

if [ $# -lt 3 ]
then
  echo "command is: run-script.sh {ip} {alluixo-path} {branch} {key-file} {user}"
  exit
fi

ip=$1
path=$2
branch=$3
keyfile=${4:-~/.ssh/aws-east.pem}
user=${5:-centos}
scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

echo Running scripts on "${ip}"

# copy over the key file
echo Copying keyfile
if ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" test -e /home/centos/.ssh/id_rsa
then
  echo Key file exists on node
else
  scp -o "StrictHostKeyChecking no" -i "${keyfile}" "${keyfile}" "${user}"@"${ip}":~/.ssh/id_rsa
fi

# do the initial setup
echo Initial setup
ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" 'BRANCH='"${branch}"' bash -s' < "${scriptDir}"/initialsetup.sh

# install perf stuff
echo Perf setup
ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" 'bash -s' < "${scriptDir}"/perf.sh

# build alluxio
echo Building alluxio
cd "${path}"
"${scriptDir}"/alluxio-build.sh "$ip" . 1 0 1 "$keyfile" "$user"

# install s3 stuff
echo S3 setup
"${scriptDir}"/s3-install.sh "$ip" "$keyfile" "$user"

#echo Running basic tests
#ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" "
#  cd alluxio
#  ./bin/alluxio format
#  ./bin/alluxio-start.sh local SudoMount
#  ./bin/alluxio runTests
#  ./bin/alluxio-stop.sh local
#"

echo Done setup at "$ip"