#!/bin/bash
set -e


if [ $# -gt 3 ]
then
  echo "command is: copy-conf-files-multiple.sh {clusterId} {key-file} {user}"
  exit
fi

clusterId=${1:-c1}
keyfile=${2:-~/.ssh/aws-east.pem}
user=${3:-centos}

siteProperties="alluxio-site.properties.cluster"
alluxioEnv="alluxio-env.sh.cluster"
log4j="log4j.properties"

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

IFS=$'\n' read -r -d '' -a ips < <( aws ec2 describe-instances --no-cli-pager --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text --filters Name=tag:clusterId,Values="${clusterId}" | sed  '/None/d' && printf '\0' )
IFS=$'\n' read -r -d '' -a privateIps < <( aws ec2 describe-instances --no-cli-pager --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text --filters Name=tag:clusterId,Values="${clusterId}" | sed  '/None/d' && printf '\0' )
IFS=$'\n' read -r -d '' -a workerIps < <( ./aws-ips.sh worker PrivateIpAddress "${clusterId}" && printf '\0' )
IFS=$'\n' read -r -d '' -a masterIps < <( ./aws-ips.sh master PrivateIpAddress "${clusterId}" && printf '\0' )

# the private ips used as masters
masterIpList=""
for ip in "${masterIps[@]}"
do
  masterIpList+="$ip
"
done

# the private ips used as workers
workerIpList=""
for ip in "${workerIps[@]}"
do
  workerIpList+="$ip
"
done

# copy masters
echo Creating masters files
for ip in "${ips[@]}"
do
  ssh -n -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" "
    echo \"${masterIpList}\" > alluxio/conf/masters
  "
done

echo Creating workers files
for ip in "${ips[@]}"
do
  ssh -n -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" "
    echo \"${workerIpList}\" > alluxio/conf/workers
  "
done

for ip in "${ips[@]}"
do
  echo Copying over alluxio-site.properties from "${scriptDir}"/${siteProperties}
  scp -o "StrictHostKeyChecking no" -i "${keyfile}" "${scriptDir}"/${siteProperties} "${user}"@"${ip}":~/alluxio/conf/alluxio-site.properties

  echo Copying over alluxio-env.sh from "${scriptDir}"/${alluxioEnv}
  scp -o "StrictHostKeyChecking no" -i "${keyfile}" "${scriptDir}"/${alluxioEnv} "${user}"@"${ip}":~/alluxio/conf/alluxio-env.sh

  echo Copying over log4j.properties from "${scriptDir}"/${log4j}
  scp -o "StrictHostKeyChecking no" -i "${keyfile}" "${scriptDir}"/${log4j} "${user}"@"${ip}":~/alluxio/conf/log4j.properties
done

addrString="alluxio.master.embedded.journal.addresses="
for ip in "${masterIps[@]}"
do
  addrString+="${ip}:19200,"
done
addrString=${addrString%?}

echo Updating ips in alluxio-site.properties
for (( j=0; j<${#ips[@]}; j++ ));
do
  ssh -n -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ips[$j]}" "
    sed -i \"s/alluxio.master.hostname=.*/alluxio.master.hostname=${privateIps[$j]}/\" alluxio/conf/alluxio-site.properties
    sed -i \"s/alluxio.master.embedded.journal.addresses=.*/${addrString}/\" alluxio/conf/alluxio-site.properties
    sed -i \"s/alluxio.master.cross.cluster.id=.*/alluxio.master.cross.cluster.id=${clusterId}/\" alluxio/conf/alluxio-site.properties
  "
done
