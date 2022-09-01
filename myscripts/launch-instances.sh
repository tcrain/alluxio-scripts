
if [ $# -lt 1 ]
then
  echo "command is: launch-instances.sh {count} {instanceType} {typeTag} {use-spot} {clusterId}"
  echo "useSpot: 0 - don't use spot instances, 1 - use spot instances"
  exit 1
fi

count=$1
instanceType=${2:-m5.xlarge}
typeTag=${3:-master,worker}
useSpot=${4:-1}
clusterId=${5:-c1}

image=ami-0e7bad923e8155ef5
key=aws-east
security=sg-0972e28f66a465737
diskSize=120
zone=us-west-1b

cat ./instance-template.json > ./instance-config.json

sed -i "" "s/\"VolumeSize\": 0/\"VolumeSize\": ${diskSize}/g" instance-config.json
sed -i "" "s/\"MaxCount\": 0/\"MaxCount\": ${count}/g" instance-config.json
sed -i "" "s/\"MinCount\": 0/\"MinCount\": ${count}/g" instance-config.json
sed -i "" "s/\"SecurityGroupIds\": \[\"\"\]/\"SecurityGroupIds\": \[\"${security}\"\]/" instance-config.json
sed -i "" "s/\"ImageId\": \"\"/\"ImageId\": \"${image}\"/" instance-config.json
sed -i "" "s/\"AvailabilityZone\": \"\"/\"AvailabilityZone\": \"${zone}\"/" instance-config.json
sed -i "" "s/\"InstanceType\": \"\"/\"InstanceType\": \"${instanceType}\"/" instance-config.json
sed -i "" "s/\"Key\": \"type\", \"Value\": \"\"/\"Key\": \"type\", \"Value\": \"${typeTag}\"/" instance-config.json
sed -i "" "s/\"Key\": \"clusterId\", \"Value\": \"\"/\"Key\": \"clusterId\", \"Value\": \"${clusterId}\"/" instance-config.json
sed -i "" "s/\"AvailabilityZone\": \"\"/\"AvailabilityZone\": \"${us-west-1b}\"/" instance-config.json
sed -i "" "s/\"KeyName\": \"\"/\"KeyName\": \"${key}\"/" instance-config.json

if [ "$useSpot" -eq 0 ]
then
  sed -i "" "s/\"MarketType\": \"spot\"//" instance-config.json
fi

cat instance-config.json
aws ec2 run-instances --cli-input-json "$(cat ./instance-config.json)" --no-cli-pager # --dry-run
# aws ec2 run-instances --image-id "$image" --count "$count" --instance-type "instanceType" --key-name "$key" --security-group-ids "$security" --tag-specifications "ResourceType=instance,Tags=[{Key=type,Value=worker}]" --generate-cli-skeleton
