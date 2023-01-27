set -e

if [ $# -lt 4 ]
then
  echo "command is: run-prof.sh {clusters} {profOptions} {procName} {outputName} {nodeType} {key-file} {user}"
  echo "eg: ./run-prof.sh c1 \"-d 10 -e cpu -o flamegraph\" AlluxioMaster cpu.html master"
  echo "eg: ./run-prof.sh c1 \"-d 10 -e cpu -o tree\" AlluxioMaster cpu.html master"
  echo "eg: ./run-prof.sh c1 \"-d 10 -e alloc -o flamegraph\" AlluxioMaster alloc.html master"
  echo "eg: ./run-prof.sh c1 \"-d 10 -e alloc -o flamegraph" "StressMasterBench.*--in-process\" alloc.html other"
  exit
fi

clusters=$1
profOptions=$2
procName=$3
outputName=$4
tag=$5
keyfile=${6:-~/.ssh/aws-east.pem}
user=${7:-centos}

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

command="./alluxio-scripts/async-prof.sh \"${profOptions}\" \"${procName}\" \"${outputName}\""

echo "Running profiler"
"${scriptDir}"/run-command-cluster.sh "${clusters}" "${command}" "${tag}" 1 "${keyfile}" "${user}"

echo "Copying results"

mkdir -p "${scriptDir}"/prof-outputs/

time=$(date '+%s')

proc=()
for clusterId in $clusters
do
  ips=$("${scriptDir}"/aws-ips.sh "$tag" PublicIpAddress "${clusterId}")
  for ip in $ips
  do
    if [ "$ip" != "" ]
    then
      outputPath="${scriptDir}"/prof-outputs/${ip}-${time}-${outputName}
      echo Copying file from ip "$ip" to "$outputPath"
      scp -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}":~/"${outputName}" "${outputPath}"  2>&1 &
      proc["${ip//\./}"]=$!
      echo
    fi
  done
done

echo "Waiting for copies to complete"
set +e
for ip in "${ips[@]}"
do
  wait ${proc["${ip//\./}"]}
  echo Exit command of ip "$ip": $?
done
