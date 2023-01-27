#!/bin/bash
set -e

if [ $# -lt 1 ]
then
  echo "command is: check-md5s.sh {path}"
  exit
fi

path=$1

while IFS= read -r -d '' file
do
  md5 "$file"
done <   <(find "$path" -name '*.jar' -type f -print0)