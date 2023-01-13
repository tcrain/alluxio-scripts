#!/bin/bash
set -e

if [ $# -gt 4 ]
then
  echo "command is: copy-conf-files-multi-cluster.sh {clusterIds} {crossClusterMasterStandalone} {key-file} {user}"
  exit
fi

clusterIds=${1:-c1}
crossClusterMasterStandalone=${2:-1}
keyfile=${3:-~/.ssh/aws-east.pem}
user=${4:-centos}

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

for clusterId in $clusterIds
do
  IFS=$'\n' read -r -d '' -a hdfsPrivateIps < <( ./aws-ips.sh hdfs PrivateIpAddress "${clusterId}" && printf '\0' )
  IFS=$'\n' read -r -d '' -a hdfsPublicIps < <( ./aws-ips.sh hdfs PublicIpAddress "${clusterId}" && printf '\0' )

  for (( j=0; j<${#hdfsPublicIps[@]}; j++ ));
  do
    echo Setting HDFS config on "${hdfsPublicIps[$j]}"
    ssh -n -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${hdfsPublicIps[$j]}" "
    echo \"<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>
    <?xml-stylesheet type=\\\"text/xsl\\\" href=\\\"configuration.xsl\\\"?>
    <configuration>
        <property>
            <name>fs.defaultFS</name>
            <value>hdfs://${hdfsPrivateIps[$j]}:9000</value>
        </property>
    </configuration>
    \" > ~/hadoop/etc/hadoop/core-site.xml
    "
  done
done

useStandalone="false"
startLocalCrossClusterMaster=1
if [ "$crossClusterMasterStandalone" -ne 0 ]
then
  useStandalone="true"
  startLocalCrossClusterMaster=0
fi

for clusterId in $clusterIds
do
  echo Updating conf in cluster "$clusterId"
  "${scriptDir}"/copy-conf-files-multiple.sh "$clusterId" "$startLocalCrossClusterMaster" "$keyfile" "$user"
  # only the first cluster will start the local master
  startLocalCrossClusterMaster=0
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
  if [ "$crossClusterMasterStandalone" -ne 0 ]
  then
    addrString+="${ip}:20009,"
    break
  else
    addrString+="${ip}:19998,"
  fi
done
addrString=${addrString%?}

echo Setting the cross cluster config addresses: "$addrString"

echo Updating cross cluster config in alluxio-site.properties
IFS=$'\n' read -r -d '' -a ips < <( aws ec2 describe-instances --no-cli-pager --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text | sed  '/None/d' && printf '\0' )
for (( j=0; j<${#ips[@]}; j++ ));
do
  ssh -n -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ips[$j]}" "
    sed -i \"s/alluxio.master.cross.cluster.rpc.addresses=.*/${addrString}/\" alluxio/conf/alluxio-site.properties
    sed -i \"s/alluxio.master.cross.cluster.enabled=.*/alluxio.master.cross.cluster.enabled=true/\" alluxio/conf/alluxio-site.properties
    sed -i \"s/alluxio.cross.cluster.master.standalone=.*/alluxio.cross.cluster.master.standalone=${useStandalone}/\" alluxio/conf/alluxio-site.properties
  "
done
