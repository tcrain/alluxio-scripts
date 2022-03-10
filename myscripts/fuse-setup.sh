#!/bin/bash
set -e

if [ "$#" -ne 3 ]
then
  echo "command is: fuse-setup.sh {enable-profile} {enable-debug} {run-type}"
  echo "0 = disable profile, debug 1 = enable"
  echo "run-type: 0 = initial setup/write 1 = read"
  exit
fi

profile=$1
debug=$2
runType=$3

if [ "$profile" -ne 0 ]
then
  masterOps="-XX:+PreserveFramePointer"
  jobMasterOps="-XX:+PreserveFramePointer"
  jobWorkerOps="-XX:+PreserveFramePointer"
  workerOps="-XX:+PreserveFramePointer"
  fuseOps="-XX:+PreserveFramePointer"
fi

if [ "$debug" -ne 0 ]
then
  masterOps+=" -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=60001"
  jobMasterOps+=" -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=60002"
  jobWorkerOps+=" -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=60003"
  workerOps+=" -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=60004"
  fuseOps+=" -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=60005"
fi

cd ~/alluxio

if [ "$runType" -eq 0 ]
then

  sudo yum -y install fuse fuse-devel

  # format journal and worker
  ./bin/alluxio-stop.sh all
  set +e
  fusermount -u ../fuseIOBench
  fusermount -u -z ../fuseIOBench

  set -e
  rm -rf ~/fuseIOBench
  ./bin/alluxio format
  rm -rf ~/alluxio/underFSStorage
  mkdir -p ~/alluxio/underFSStorage

  ALLUXIO_MASTER_ATTACH_OPTS="$masterOps" ALLUXIO_JOB_MASTER_ATTACH_OPTS="$jobMasterOps" ALLUXIO_JOB_WORKER_ATTACH_OPTS="$jobWorkerOps" ALLUXIO_WORKER_ATTACH_OPTS="$workerOps" ./bin/alluxio-start.sh local SudoMount

  ./bin/alluxio fs mkdir /fuseIOBench
  mkdir -p ~/fuseIOBench
  chmod 755 ~/fuseIOBench
  ALLUXIO_FUSE_ATTACH_OPTS="$fuseOps" ./integration/fuse/bin/alluxio-fuse mount ~/fuseIOBench /fuseIOBench
  ./integration/fuse/bin/alluxio-fuse stat

  echo Running: ./bin/alluxio runClass alluxio.stress.cli.fuse.FuseIOBench --operation Write --local-path ~/fuseIOBench --num-dirs 128 --num-files-per-dir 100 --file-size 1m --threads 32
  ./bin/alluxio runClass alluxio.stress.cli.fuse.FuseIOBench --operation Write --local-path ~/fuseIOBench --num-dirs 128 --num-files-per-dir 100 --file-size 1m --threads 32

elif [ "$runType" -eq 1 ]
then

  echo Running: ./bin/alluxio runClass alluxio.stress.cli.fuse.FuseIOBench --operation LocalRead --local-path ~/fuseIOBench --num-dirs 128 --num-files-per-dir 100 --file-size 1m --buffer-size 512k --warmup 30s --duration 30s
  ./bin/alluxio runClass alluxio.stress.cli.fuse.FuseIOBench --operation LocalRead --local-path ~/fuseIOBench --num-dirs 128 --num-files-per-dir 100 --file-size 1m --buffer-size 512k --warmup 30s --duration 30s

else
  echo Invalid run type: $runType
fi