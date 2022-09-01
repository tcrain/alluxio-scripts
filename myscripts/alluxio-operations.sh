
~/alluxio/bin/alluxio fsadmin journal checkpoint

~/alluxio/bin/alluxio fs ls -R -Dalluxio.user.file.metadata.sync.interval=0 /

~/alluxio/bin/alluxio fs startSync /

~/alluxio/bin/alluxio fs stopSync /

~/alluxio/bin/alluxio fs getSyncPathList

~/alluxio/bin/alluxio fsadmin report

~/alluxio/bin/alluxio fsadmin report ufs

~/alluxio/bin/alluxio fsadmin journal quorum info -domain MASTER

~/alluxio/bin/alluxio fsadmin journal quorum elect -address 172.31.30.151:19200

~/alluxio/bin/alluxio fs mount /mnt/local ~/underFSStorage/

~/alluxio/bin/alluxio fs loadMetadata -R -F /mnt/local


~/alluxio/bin/alluxio-start.sh all SudoMount

tail -F ~/alluxio/logs/cross-cluster.log

~/alluxio/bin/alluxio fs mkdir /mnt; ~/alluxio/bin/alluxio fs mount --crosscluster /mnt/s3crosscluster s3://alluxiotyler/

./command-scripts/get-cross-cluster-latency-command.sh "c1 c2" "/mnt/s3crosscluster"

~/alluxio/bin/alluxio fs unmount /mnt/s3crosscluster

~/alluxio/bin/alluxio fs touch /mnt/s3crosscluster/touch1

~/alluxio/bin/alluxio fs mkdir /mnt; ~/alluxio/bin/alluxio fs mount /mnt/s3timeSync s3://alluxiotyler2/

./command-scripts/get-cross-cluster-latency-command.sh "c1 c2" "/mnt/s3timeSync"

~/alluxio/bin/alluxio fs unmount /mnt/s3timeSync