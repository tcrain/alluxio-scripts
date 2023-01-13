#!/bin/bash
set -e

if [ $# -lt 2 ]
then
  echo "command is: run-script-multiple.sh {path} {branch} {cluster-ids} {buildAlluxio} {buildBenches} {format} {key-file} {user}"
  exit
fi

path=$1
branch=$2
clusterIds=${3:-c1}
buildAlluxio=${4:-1}
buildBenches=${5:-0}
format=${6:-1}
keyfile=${7:-~/.ssh/aws-east.pem}
user=${8:-centos}

# by default use a cross cluster master standalone
crossClusterMasterStandalone=1

IFS=$'\n' read -r -d '' -a ips < <( aws ec2 describe-instances --no-cli-pager --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text | sed  '/None/d' && printf '\0' )

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
logs="${scriptDir}/logs/build-$(date '+%s')"
mkdir -p "$logs"

echo Running command on ips:
echo "${ips[@]}"

proc=()
for ip in "${ips[@]}"
do
  echo Running: "${scriptDir}"/run-scripts.sh "$ip" "$path" "$branch" "$keyfile" "$user", logging to "${logs}"/run-scripts-"${ip}"

  # build alluxio
  buildAlluxio=1
  echo Building alluxio with build option: ip: "$ip" path: "${path}" buildAlluxio: "${buildAlluxio}" buildBenches: "$buildBenches" format: "${format}"
  "${scriptDir}"/alluxio-build.sh "$ip" "${path}" "${buildAlluxio}" "$buildBenches" "${format}" "$keyfile" "$user"  > "${logs}"/run-scripts-"${ip}" 2>&1 &
  proc["${ip//\./}"]=$!
done

echo "Waiting for scripts to complete"
set +e
for ip in "${ips[@]}"
do
  wait ${proc["${ip//\./}"]}
  echo Exit command of ip "$ip": $?
done

set -e

"${scriptDir}"/copy-conf-files-multi-cluster.sh "$clusterIds" "$crossClusterMasterStandalone" "$keyfile" "$user"

echo Done running command on ips:
echo "${ips[@]}"
