set -e

if [ $# -gt 2 ]
then
  echo "command is: run-command.sh {key-file} {user}"
  exit
fi

keyfile=${1:-~/.ssh/aws-east.pem}
user=${2:-centos}

ips=$(aws ec2 describe-instances --no-cli-pager --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text | sed  '/None/d')

for ip in $ips
do
  ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}"  -t "
  rm -rf /home/centos/alluxio/logs
  mkdir /home/centos/alluxio/logs
  "
done
