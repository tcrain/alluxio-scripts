set -e

masterCount=1
workerCount=1
otherCount=1
useSpot=1

#./launch-instances.sh "$masterCount" m5.2xlarge master 0
#./launch-instances.sh "$workerCount" m5.2xlarge worker 0
#./launch-instances.sh "$otherCount" c5.2xlarge other 0

./launch-instances.sh "$masterCount" c5.9xlarge master,worker $useSpot c1
#./launch-instances.sh "$masterCount" m5.4xlarge master,worker $useSpot c2
#./launch-instances.sh "$masterCount" c5.2xlarge master,worker $useSpot c3

./launch-instances.sh "$otherCount" c5.9xlarge other $useSpot c1

# ./launch-instances.sh 1 m5.4xlarge hdfs $useSpot c1
