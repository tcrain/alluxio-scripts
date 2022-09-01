#!/bin/bash
set -e

if [ "$#" -lt 2 ]
then
  echo "command is: alluxio-start.sh {enable-profile} {enable-debug} {format}"
  echo "0 = disable profile/debug 1 = enable"
  exit 1
fi

profile=$1
debug=$2
format=${3:-0}

if [ "$format" -ne 0 ]
then
  # format journal and worker
  ~/alluxio/bin/alluxio-stop.sh all
  ~/alluxio/bin/alluxio format
fi

if [ "$profile" -ne 0 ]
then
  masterOps="-XX:+PreserveFramePointer"
  jobMasterOps="-XX:+PreserveFramePointer"
  jobWorkerOps="-XX:+PreserveFramePointer"
  workerOps="-XX:+PreserveFramePointer"
fi

if [ "$debug" -ne 0 ]
then
  masterOps+=" -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=60001"
  jobMasterOps+=" -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=60002"
  jobWorkerOps+=" -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=60003"
  workerOps+=" -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=60004"
fi

ALLUXIO_MASTER_ATTACH_OPTS="$masterOps" ALLUXIO_JOB_MASTER_ATTACH_OPTS="$jobMasterOps" ALLUXIO_JOB_WORKER_ATTACH_OPTS="$jobWorkerOps" ALLUXIO_WORKER_ATTACH_OPTS="$workerOps" ~/alluxio/bin/alluxio-start.sh local SudoMount

~/alluxio/bin/alluxio fsadmin report
~/alluxio/bin/alluxio fsadmin report ufs
~/alluxio/bin/alluxio fsadmin journal quorum info -domain MASTER