#!/bin/bash
set -e

if [ "$#" -lt 3 ]
then
  echo "command is: async-prof.sh {profOptions} {processName} {outputName}"
  echo "0 = disable profile/debug 1 = enable"
  exit 1
fi

profOptions=${1}
processName=${2}
outputName=${3}

# profOptions must not be in quotes because it must be expanded
~/async-profiler-2.8-linux-x64/profiler.sh ${profOptions} "$(jps -m | grep "${processName}" | cut -d ' ' -f1 | head -n 1 -)" > "${outputName}"
