#!/bin/bash
set -e

if [ $# -gt 3 ]
then
  echo "command is: copy-conf-files-multi-cluster.sh {clusterIds} {key-file} {user}"
  exit
fi

clusterIds=${1:-c1}
keyfile=${2:-~/.ssh/aws-east.pem}
user=${3:-centos}

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

for clusterId in $clusterIds
do
  echo Updating conf in cluster "$clusterId"
  "${scriptDir}"/copy-conf-files-multiple.sh "$clusterId" "$keyfile" "$user"
done

for clusterId in $clusterIds
do
  # the first cluster id is used as the configuration cluster
  IFS=$'\n' read -r -d '' -a masterIps < <( ./aws-ips.sh master PrivateIpAddress "${clusterId}" && printf '\0' )
  break
done

addrString="alluxio.master.cross.cluster.rpc.addresses="
for ip in "${masterIps[@]}"
do
  addrString+="${ip}:19998,"
done
addrString=${addrString%?}

echo Setting the cross cluster config addresses: "$addrString"

echo Updating cross cluster config in alluxio-site.properties
IFS=$'\n' read -r -d '' -a ips < <( aws ec2 describe-instances --no-cli-pager --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text | sed  '/None/d' && printf '\0' )
for (( j=0; j<${#ips[@]}; j++ ));
do
  ssh -n -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ips[$j]}" "
    sed -i \"s/alluxio.master.cross.cluster.rpc.addresses=.*/${addrString}/\" alluxio/conf/alluxio-site.properties
    sed -i \"s/alluxio.master.cross.cluster.enable=.*/alluxio.master.cross.cluster.enable=true/\" alluxio/conf/alluxio-site.properties
  "
done
