#!/bin/bash
set -e

if [ $# -lt 2 ]
then
  echo "command is: run-script-multiple.sh {alluixo-path} {branch} {cluster-ids} {key-file} {user}"
  exit
fi

path=$1
branch=$2
clusterIds=${3:-c1}
keyfile=${4:-~/.ssh/aws-east.pem}
user=${5:-centos}

IFS=$'\n' read -r -d '' -a ips < <( aws ec2 describe-instances --no-cli-pager --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text | sed  '/None/d' && printf '\0' )

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
logs="${scriptDir}/logs/$(date '+%s')"
mkdir -p "$logs"

echo Running command on ips:
echo "${ips[@]}"

proc=()
for ip in "${ips[@]}"
do
  echo Running: "${scriptDir}"/run-scripts.sh "$ip" "$path" "$branch" "$keyfile" "$user", logging to "${logs}"/run-scripts-"${ip}"
  "${scriptDir}"/run-scripts.sh "$ip" "$path" "$branch" "$keyfile" "$user" > "${logs}"/run-scripts-"${ip}" 2>&1 &
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

"${scriptDir}"/copy-conf-files-multi-cluster.sh "$clusterIds" "$keyfile" "$user"

echo Done running command on ips:
echo "${ips[@]}"
