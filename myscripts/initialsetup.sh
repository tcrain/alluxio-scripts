#!/bin/bash
set -e

alluxiogit="https://github.com/tcrain/alluxio.git"
alluxiobranch=$BRANCH

sudo yum -y install epel-release
sudo yum -y update
sudo yum -y install git libevent-devel ncurses-devel gcc make bison pkg-config java-1.8.0-openjdk-devel wget htop iftop emacs
sudo yum -y install perf gawk cmake
sudo yum -y group install "Development Tools"

echo Setting file ulimit

echo "fs.file-max = 1048576" | sudo tee -a /etc/sysctl.conf

echo "*         hard    nofile      1048576
*         soft    nofile      1048576
root      hard    nofile      1048576
root      soft    nofile      1048576" | sudo tee -a /etc/security/limits.conf

sudo sysctl -p

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

asyncProfVer="2.8"
asyncProfName="async-profiler-${asyncProfVer}-linux-x64"
wget "https://github.com/jvm-profiling-tools/async-profiler/releases/download/v${asyncProfVer}/${asyncProfName}.tar.gz"
tar xvzf ${asyncProfName}.tar.gz
echo export LD_LIBRARY_PATH=~/${asyncProfName}/build/:"${LD_LIBRARY_PATH}" >> ~/.bashrc
echo kernel.kptr_restrict=0 | sudo tee -a /usr/lib/sysctl.d/01-system.conf
echo kernel.perf_event_paranoid=1 | sudo tee -a /usr/lib/sysctl.d/01-system.conf
sudo sysctl -p /usr/lib/sysctl.d/01-system.conf


# https://download.yourkit.com/yjp/2022.3/YourKit-JavaProfiler-2022.3-b107.zip
yourKitDate="2022.3"
yourKitVersion="b107"
rm -rf YourKit
wget https://download.yourkit.com/yjp/${yourKitDate}/YourKit-JavaProfiler-${yourKitDate}-${yourKitVersion}.zip
unzip -o YourKit-JavaProfiler-${yourKitDate}-${yourKitVersion}.zip
mv YourKit-JavaProfiler-${yourKitDate} YourKit

rm -rf alluxio
git clone "${alluxiogit}"
cd alluxio

git checkout "$alluxiobranch"
echo export ALLUXIO_HOME=~/alluxio >> ~/.bashrc
source ~/.bashrc
mkdir -p ./underFSStorage
mkdir -p  ~/alluxio-scripts
