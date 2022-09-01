#!/bin/bash
set -e

if [ "$#" -ne 3 ]
then
  echo "command is: fuse-setup.sh {enable-profile} {enable-debug} {run-type}"
  echo "0 = disable profile, debug 1 = enable"
  echo "run-type: 0 = install, 1 = initial setup, 2 = write, 3 = read"
  exit 1
fi

profile=$1
debug=$2
runType=$3

cd ~/alluxio

if [ "$runType" -eq 0 ]
then

  sudo yum -y install fuse fuse-devel fuse3

elif [ "$runType" -eq 1 ]
then

  if [ "$profile" -ne 0 ]
  then
    fuseOps="-XX:+PreserveFramePointer"
  fi

  if [ "$debug" -ne 0 ]
  then
    fuseOps+=" -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=60005"
  fi

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

  ~/alluxio-scripts/alluxio-start.sh "$profile" "$debug"

  ./bin/alluxio fs mkdir /fuseIOBench
  mkdir -p ~/fuseIOBench
  chmod 755 ~/fuseIOBench
  ALLUXIO_FUSE_ATTACH_OPTS="$fuseOps" ./integration/fuse/bin/alluxio-fuse mount ~/fuseIOBench /fuseIOBench
  ./integration/fuse/bin/alluxio-fuse stat

elif [ "$runType" -eq 2 ]
then

  echo Running: ./bin/alluxio runClass alluxio.stress.cli.fuse.FuseIOBench --operation Write --local-path ~/fuseIOBench --num-dirs 128 --num-files-per-dir 100 --file-size 1m --threads 32
  ./bin/alluxio runClass alluxio.stress.cli.fuse.FuseIOBench --operation Write --local-path ~/fuseIOBench --num-dirs 128 --num-files-per-dir 100 --file-size 1m --threads 32

elif [ "$runType" -eq 3 ]
then

  echo Running: ./bin/alluxio runClass alluxio.stress.cli.fuse.FuseIOBench --operation LocalRead --local-path ~/fuseIOBench --num-dirs 128 --num-files-per-dir 100 --file-size 1m --buffer-size 512k --warmup 30s --duration 30s
  ./bin/alluxio runClass alluxio.stress.cli.fuse.FuseIOBench --operation LocalRead --local-path ~/fuseIOBench --num-dirs 128 --num-files-per-dir 100 --file-size 1m --buffer-size 512k --warmup 30s --duration 30s

else
  echo Invalid run type: "$runType"
fi