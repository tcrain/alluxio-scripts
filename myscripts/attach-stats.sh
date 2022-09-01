#!/bin/bash
set -e

if [ $# -lt 1 ]
then
  echo "command is: attach-stats.sh {ip} {key-file} {user}"
  exit 1
fi

ip=$1
keyfile=${2:-~/.ssh/aws-east.pem}
user=${3:-centos}

ssh -o "StrictHostKeyChecking no" -i "${keyfile}" "${user}"@"${ip}"  -t '
session=stats

tmux kill-session -t $session

tmux new-session -d -s $session

tmux send-keys -t $session:0 "htop" C-m

tmux split-window -h

tmux send-keys "sudo iftop" C-m H

tmux split-window -v

tmux send-keys "tail -F ~/alluxio/logs/master.log" C-m

tmux select-pane -t 0

tmux split-window -v

tmux attach-session -d -t $session

'

#tmux new-window -t $session:1
#tmux new-window -t $session:2
#tmux send-keys -t $session:2 "tail -F ~/alluxio/logs/master.log" C-m


