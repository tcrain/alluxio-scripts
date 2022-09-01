set -e

if [ $# -lt 2 ]
then
  echo "command is: run-command.sh {clusters} {command} {key-file} {user}"
  exit
fi

clusters=$1
command=$2
keyfile=${3:-~/.ssh/aws-east.pem}
user=${4:-centos}

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

for clusterId in $clusters
do
  ip=$("${scriptDir}"/aws-ips.sh master PublicIpAddress "${clusterId}" | head -n 1)
  echo Running "$command" on ip "$ip"
  ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" "$command"
  echo
done