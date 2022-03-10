#!/bin/bash
set -e

alluxiogit="https://github.com/tcrain/alluxio.git"

sudo yum -y install epel-release
sudo yum -y update
sudo yum -y install git libevent-devel ncurses-devel gcc make bison pkg-config java-1.8.0-openjdk-devel wget htop iftop

echo export JAVA_HOME=/usr/lib/jvm/java >> ~/.bashrc
echo set -g pane-border-status top >> ~/.tmux.conf

tmuxVer="3.2a"
wget https://github.com/tmux/tmux/releases/download/3.2a/tmux-${tmuxVer}.tar.gz
tar -zxf tmux-${tmuxVer}.tar.gz
cd tmux-${tmuxVer}/
./configure --prefix=/usr
make && sudo make install
cd .. && rm -rf ./tmux-${tmuxVer} && rm tmux-${tmuxVer}.tar.gz

wget https://dlcdn.apache.org/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz
tar xzvf apache-maven-3.8.4-bin.tar.gz
rm apache-maven-3.8.4-bin.tar.gz
echo export PATH=~/apache-maven-3.8.4/bin:$PATH >> ~/.bashrc

git clone "${alluxiogit}"
echo export ALLUXIO_HOME=~/alluxio >> ~/.bashrc
source ~/.bashrc

cd alluxio
# copy the properties
cat ~/alluxio-site.properties >> ./conf/alluxio-site.properties

mkdir ./underFSStorage
