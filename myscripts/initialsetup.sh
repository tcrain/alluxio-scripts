#!/bin/bash
set -e

alluxiogit="https://github.com/tcrain/alluxio.git"

sudo yum -y install epel-release
sudo yum -y update
sudo yum -y install git libevent-devel ncurses-devel gcc make bison pkg-config java-1.8.0-openjdk-devel wget htop iftop
sudo yum -y install perf gawk cmake
sudo yum -y group install "Development Tools"

echo export JAVA_HOME=/usr/lib/jvm/java >> ~/.bashrc
echo set -g pane-border-status top >> ~/.tmux.conf

tmuxVer="3.2a"
wget https://github.com/tmux/tmux/releases/download/3.2a/tmux-${tmuxVer}.tar.gz
tar -zxf tmux-${tmuxVer}.tar.gz
cd tmux-${tmuxVer}/
./configure --prefix=/usr
make && sudo make install
cd .. && rm -rf ./tmux-${tmuxVer} && rm tmux-${tmuxVer}.tar.gz

mvnVer="3.8.4"
wget https://archive.apache.org/dist/maven/maven-3/${mvnVer}/binaries/apache-maven-${mvnVer}-bin.tar.gz
tar xzvf apache-maven-${mvnVer}-bin.tar.gz
rm apache-maven-${mvnVer}-bin.tar.gz
echo export PATH=~/apache-maven-${mvnVer}/bin:$PATH >> ~/.bashrc

git clone "${alluxiogit}"
echo export ALLUXIO_HOME=~/alluxio >> ~/.bashrc
source ~/.bashrc

cd alluxio
mkdir -p ./underFSStorage
mkdir -p  ~/alluxio-scripts
