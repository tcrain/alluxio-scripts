set -e

if [ $# -gt 1 ]
then
  echo "command is: get-ips.sh {clusterId}"
  exit 1
fi

clusterId=${1:-c1}

echo EC2 Private IPs
aws ec2 describe-instances --no-cli-pager --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text | sed  '/None/d'
echo EC2 Public IPs
aws ec2 describe-instances --no-cli-pager --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text | sed  '/None/d'
echo
echo IPs for cluster "$clusterId"
echo EC2 master Public IPs
./aws-ips.sh master PublicIpAddress "${clusterId}"
echo EC2 master Private IPs
./aws-ips.sh master PrivateIpAddress "${clusterId}"
echo
echo EC2 worker Public IPs
./aws-ips.sh worker PublicIpAddress "${clusterId}"
echo EC2 worker Private IPs
./aws-ips.sh worker PrivateIpAddress "${clusterId}"
echo
echo EC2 other Public IPs
./aws-ips.sh other PublicIpAddress "${clusterId}"
echo EC2 other Private IPs
./aws-ips.sh other PrivateIpAddress "${clusterId}"