set -e

if [ $# -gt 2 ]
then
  echo "command is: copy-logs.sh {key-file} {user}"
  exit
fi

keyfile=${1:-~/.ssh/aws-east.pem}
user=${2:-centos}

logs="node-logs$(date '+%s')"

nodeTypes="master worker other"
for nodeType in $nodeTypes
do
  echo Copying logs for node type "$nodeType"
  ips=$(./aws-ips.sh "${nodeType}" PublicIpAddress)
  ./copy-logs-ip.sh "$ips" "$nodeType" ./logs/"$logs" "$keyfile" "$user"
done

echo Taring files: tar -czf ./logs/"$logs".tar.gz ./logs/"$logs"
tar -czf ./logs/"$logs".tar.gz ./logs/"$logs"
