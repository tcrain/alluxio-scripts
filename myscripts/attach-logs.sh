#!/bin/bash
set -e

if [ $# -lt 1 ]
then
  echo "command is: attach-stats.sh {ip} {key-file} {user}"
  exit
fi

ip=$1
keyfile=${2:-~/.ssh/aws-east.pem}
user=${3:-centos}

ssh -o "StrictHostKeyChecking no" -i ${keyfile} ${user}@${ip}  -t "
session=logs

tmux kill-session -t \$session

tmux new-session -d -s \$session

tmux send-keys \"printf '\033]2;%s\033\\' 'master.log'\" C-m
tmux send-keys \"tail -F ~/alluxio/logs/master.log\" C-m

tmux split-window -v -p 66

tmux send-keys \"printf '\033]2;%s\033\\' 'job_master.log'\" C-m
tmux send-keys \"tail -F ~/alluxio/logs/job_master.log\" C-m

tmux split-window -v

tmux send-keys \"printf '\033]2;%s\033\\' 'worker.log'\" C-m
tmux send-keys \"tail -F ~/alluxio/logs/worker.log\" C-m

tmux select-pane -t 0

tmux split-window -h

tmux send-keys \"printf '\033]2;%s\033\\' 'fuse.log'\" C-m
tmux send-keys \"tail -F ~/alluxio/logs/fuse.log\" C-m

tmux select-pane -t 2

tmux split-window -h

tmux send-keys \"printf '\033]2;%s\033\\' 'error logs'\" C-m
tmux send-keys \"tail -F ~/alluxio/logs/fuse.log ~/alluxio/logs/fuse.log ~/alluxio/logs/fuse.log ~/alluxio/logs/fuse.log | grep -i '<==\|error'\" C-m

tmux select-pane -t 4

tmux split-window -h

tmux attach-session -d -t \$session

"

#tmux send-keys "tail -F ~/alluxio/logs/fuse.log ~/alluxio/logs/fuse.log ~/alluxio/logs/fuse.log ~/alluxio/logs/fuse.log | grep -i \'\<==\|error\'" C-m

#tmux new-window -t $session:1
#tmux new-window -t $session:2
#tmux send-keys -t $session:2 "tail -F ~/alluxio/logs/master.log" C-m


