set -e

masterCount=1
workerCount=1
otherCount=1

#./launch-instances.sh "$masterCount" m5.2xlarge master 0
#./launch-instances.sh "$workerCount" m5.2xlarge worker 0
#./launch-instances.sh "$otherCount" c5.2xlarge other 0

./launch-instances.sh "$masterCount" m5.4xlarge master,worker 1 c1
#./launch-instances.sh "$masterCount" m5.4xlarge master,worker 1 c2
#./launch-instances.sh "$masterCount" c5.2xlarge master,worker 1 c3

./launch-instances.sh "$otherCount" c5.4xlarge other 1 c1

# ./launch-instances.sh 1 m5.4xlarge hdfs 1 c1
