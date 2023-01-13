set -e

if [ $# -lt 2 ]
then
  echo "command is: run-command.sh {clusters} {command} {tag} {key-file} {user}"
  exit
fi

clusters=$1
command=$2
tag=${3:-master}
keyfile=${4:-~/.ssh/aws-east.pem}
user=${5:-centos}

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

for clusterId in $clusters
do
  ip=$("${scriptDir}"/aws-ips.sh "$tag" PublicIpAddress "${clusterId}" | head -n 1)
  if [ "$ip" != "" ]
  then
    echo Running "$command" on ip "$ip"
    ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" "$command"
    echo
  fi
done