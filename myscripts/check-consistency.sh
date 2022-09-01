#!/bin/bash
#
# SCRIPT: refreshPaths.sh
#
# USAGE: nohup ./refreshPaths.sh > ./refreshPaths-`date "+%Y_%m_%d_%H_%M_%S"`.txt 2>&1 &

source_dir="/alluxio-compaction-benchmark/source"
worker_dirs=""

echo
echo " `date` - Begin output from script: refreshPaths.sh"
echo
for worker_dir in `echo $worker_dirs`; do

    echo
    echo " --- `date` - Running commands against worker_dir: $worker_dir"

    dir_num=0
    while [[ $dir_num -lt 101 ]] ; do
        next_batch=$((dir_num+20))

        display_next_batch=$((next_batch-1))
        echo
        echo "    --- `date` - Running next batch of 20 concurrent commands for: $dir_num through $display_next_batch"

        while [ $dir_num -lt $next_batch ]; do

            echo "      --- nohup /opt/alluxio/bin/alluxio fs checkConsistency -r ${source_dir}/${worker_dir}/${dir_num}/ &"
            #nohup /opt/alluxio/bin/alluxio fs checkConsistency -r ${source_dir}/${worker_dir}/${dir_num}/ > check-consistency-${worker_dir}-${dir_num}-`date "+%Y_%m_%d_%H_%M_%S"`.out 2>&1 &

            let "dir_num++"
         done

         echo "      --- Waiting for batch to complete..."
         while true; do

             still_running=$(ps -ef | grep -e "alluxio fs checkConsistency" -e "alluxio fs ls -fR" | grep -v grep)

             if [ "$still_running" != "" ]; then
                  # Some commands are still running, continue waiting
                  echo -n "."
                  sleep 10
                  continue
             else
                  dir_num=$((next_batch+1))
                  break
             fi
         done
     done
done

echo
echo " `date` - End output from script: refreshPaths.sh"
echo
# end of script
EOF