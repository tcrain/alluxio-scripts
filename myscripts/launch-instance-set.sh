set -e

masterCount=2
workerCount=1
otherCount=1

#./launch-instances.sh "$masterCount" m5.2xlarge master 0
#./launch-instances.sh "$workerCount" m5.2xlarge worker 0
#./launch-instances.sh "$otherCount" c5.2xlarge other 0

./launch-instances.sh "$masterCount" c5.2xlarge master,worker 1
#./launch-instances.sh "$otherCount" c5.2xlarge other 1