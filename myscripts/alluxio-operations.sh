
~/alluxio/bin/alluxio fsadmin journal checkpoint

~/alluxio/bin/alluxio fs ls -R -Dalluxio.user.file.metadata.sync.interval=0 /

~/alluxio/bin/alluxio fs startSync /

~/alluxio/bin/alluxio fs stopSync /

~/alluxio/bin/alluxio fs getSyncPathList

