set -e

if [ $# -lt 3 ]
then
  echo "command is: copy-logs-ip.sh {ips} {node-name} {log-path} {key-file} {user}"
  exit
fi


ips=$1
name=$2
path=$3
keyfile=${4:-~/.ssh/aws-east.pem}
user=${5:-centos}

for ip in $ips
do
  logPath="${path}/${name}-${ip}"
  mkdir -p "$logPath"

  echo Syncing logs:  rsync -ave "ssh -i ${keyfile}" "${user}"@"${ip}":~/alluxio/logs "$logPath"
  rsync -ave "ssh -i ${keyfile}" "${user}"@"${ip}":~/alluxio/logs "$logPath"

  echo Syncing conf:  rsync -ave "ssh -i ${keyfile}" "${user}"@"${ip}":~/alluxio/conf "$logPath"
  rsync -ave "ssh -i ${keyfile}" "${user}"@"${ip}":~/alluxio/conf "$logPath"

done