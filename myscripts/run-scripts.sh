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
scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# copy over the key file
scp -o "StrictHostKeyChecking no" -i "${keyfile}" "${keyfile}" "${user}"@"${ip}":~/.ssh/id_rsa

# do the initial setup
ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" 'bash -s' < "${scriptDir}"/initialsetup.sh

# install perf stuff
ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" 'bash -s' < "${scriptDir}"/perf.sh

# build alluxio
cd "${path}"
"${scriptDir}"/alluxio-build.sh "$ip" . 1 0 "$keyfile" "$user"

ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" "
  cd alluxio
  ./bin/alluxio format
  ./bin/alluxio-start.sh local SudoMount
  ./bin/alluxio runTests
  ./bin/alluxio-stop.sh local
"