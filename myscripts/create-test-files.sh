#!/bin/bash
#
# SCRIPT: create-test-files.sh
#
# USAGE:  nohup ./create-test-files.sh > create-test-files-`date '+%Y-%m-%d_%H_%M_%S'`.txt 2>&1 &

base_dir="/alluxio-metadata-sync-test-replacement"
test_dirs="test_1 test_2 test_3 test_4 test_5 test_6 test_7 test_8 test_9 test_10"
number_of_threads=56

# In each test_dir, create 100 directories and place 7,000 new files in each directory
echo " `date` - Begin create-test-files.sh"

# Create 7,000 test files
temp_test_dir=/tmp/metadata_sync_test_files
echo " `date` - Creating 100 directories x 7000 test files in ${temp_test_dir}"
rm -rf ${temp_test_dir}
for dir_number in {1..100}
do
  mkdir -p ${temp_test_dir}/dir_${dir_number}
  for file_number in {1..7000}
  do
    echo "TEST FILE ${file_number}" > ${temp_test_dir}/dir_${dir_number}/file_${file_number}.txt
  done
done

echo Running ./bin/alluxio fs rm -R ${base_dir} #&> /dev/null
./bin/alluxio fs rm -R ${base_dir} #&> /dev/null
echo Exit value: $?

echo Running ./bin/alluxio fs mkdir ${base_dir} #&> /dev/null
./bin/alluxio fs mkdir ${base_dir} #&> /dev/null
echo Exit value: $?

for test_dir in `echo $test_dirs`
do
  echo "    `date` - Creating files in ${base_dir}/${test_dir}"
  echo Running: ./bin/alluxio fs mkdir ${base_dir}/${test_dir} #&> /dev/null
  ./bin/alluxio fs mkdir ${base_dir}/${test_dir} #&> /dev/null
  echo Exit value: $?

  echo Running: ./bin/alluxio fs copyFromLocal --thread ${number_of_threads} --buffersize 20000000 ${temp_test_dir} ${base_dir}/${test_dir}/ #&> /dev/null

  ./bin/alluxio fs copyFromLocal --thread ${number_of_threads} \
      --buffersize 20000000 ${temp_test_dir} ${base_dir}/${test_dir}/ #&> /dev/null
echo Exit value: $?

done

echo Running: rm -rf ${temp_test_dir}
rm -rf ${temp_test_dir}

echo " `date` - End create-test-files.sh"
# end of script