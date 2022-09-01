
if [ $# -lt 2 ]
then
  echo "command is: aws-ips.sh {tag} {ipType} {clusterId}"
  exit 1
fi

tag=$1
ipType=$2
clusterId=${3:c1}

aws ec2 describe-instances --no-cli-pager --query "Reservations[*].Instances[*].[$ipType]" --output text --filters "Name=tag:type,Values=*${tag}*" "Name=tag:clusterId,Values=${clusterId}" | sed  '/None/d'
