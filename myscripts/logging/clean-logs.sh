set -e

path=$1

find "$path" -name '*.log.*' -print0 | while IFS= read -r -d '' file
do
  echo "$file"
  sed -i '' '/alluxio.exception.FileDoesNotExistException/d
  /ttlAction: DELETE/d
  /ttl:/d
  /InodeSyncStream/d' "$file"
done
