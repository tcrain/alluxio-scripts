
for i in {1..20}
do
  ./create-test-files.sh &> ./logs/create-test-files-"${i}".log
done
