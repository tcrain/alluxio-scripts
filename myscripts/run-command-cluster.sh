set -e

if [ $# -lt 2 ]
then
  echo "command is: run-command.sh {clusters} {command} {tag} {run-on-each} {key-file} {user}"
  echo "0 = run on single/debug 1 = run on each"
  exit
fi

clusters=$1
command=$2
tag=${3:-master}
runOnEach=${4:0}
keyfile=${5:-~/.ssh/aws-east.pem}
user=${6:-centos}

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

proc=()
for clusterId in $clusters
do
  ips=$("${scriptDir}"/aws-ips.sh "$tag" PublicIpAddress "${clusterId}")
  if [ "$runOnEach" -eq 0 ]
  then
     ips=$(echo "$ips" | head -n 1)
  fi
  for ip in $ips
  do
    if [ "$ip" != "" ]
    then
      echo Running "$command" on ip "$ip"
      ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}" "$command"  2>&1 &
      proc["${ip//\./}"]=$!
      echo
    fi
  done
done

echo "Waiting for scripts to complete"
set +e
for ip in "${ips[@]}"
do
  wait ${proc["${ip//\./}"]}
  echo Exit command of ip "$ip": $?
done
