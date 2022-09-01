
mk_files() {
  mkdir "$path"/dir"$1"
  for ((f=1; f <= fileCount; f++))
  do
    touch "$path"/dir"$1"/file"$f"
  done
}

dirCount=100
fileCount=100000
path="$HOME/git/alluxio/underFSStorage/tmpFiles/scriptgen"
mkdir -p "$path"
echo Making $fileCount files in $dirCount directories

for ((d=1; d <= dirCount; d++))
do
  mk_files "$d" &
done

wait
echo "Done making files"