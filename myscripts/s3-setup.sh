#!/bin/bash
set -e

if [ "$#" -ne 3 ]
then
  echo "command is: s3-setup.sh {enable-profile} {enable-debug} {run-type} {bucket-name}"
  echo "0 = disable profile, debug 1 = enable"
  echo "run-type: 0 = initial setup"
  exit
fi

profile=$1
debug=$2
runType=$3
bucketName=${4:-alluxiotyler}
mountPath=${5:-/s3}

if [ "$runType" -eq 0 ]
then

  echo "alluxio.master.mount.table.root.ufs=s3://${bucketName}" >> ~/alluxio/conf/alluxio-site.properties

  # format journal and worker
  ~/alluxio/bin/alluxio-stop.sh all
  ~/alluxio/bin/alluxio format

  # start alluxio
  ~/alluxio-scripts/alluxio-start.sh "$profile" "$debug"

  # mount the bucket
  ~/alluxio/bin/alluxio fs mount "${mountPath}" s3://"${bucketName}"

  # be sure we can read it in alluxio
  listing=$(~/alluxio/bin/alluxio fs ls -R -Dalluxio.user.file.metadata.sync.interval=0 /)
  echo "$listing"
  if [ "$(echo "$listing" | wc -l)" -lt 1 ]
  then
    echo "Empty listing of alluxio file system"
    exit 1
  fi

fi