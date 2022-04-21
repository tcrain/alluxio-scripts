#!/bin/bash
set -e

alluxioGit="https://github.com/alluxio/alluxio.git"

sudo yum -y install epel-release
sudo yum -y update
sudo yum -y install git libevent-devel ncurses-devel gcc make bison pkg-config java-1.8.0-openjdk-devel wget htop iftop pdsh

echo export JAVA_HOME=/usr/lib/jvm/java >> ~/.bashrc

mvnVer="3.8.5"
wget https://archive.apache.org/dist/maven/maven-3/${mvnVer}/binaries/apache-maven-${mvnVer}-bin.tar.gz
tar xzvf apache-maven-${mvnVer}-bin.tar.gz
rm apache-maven-${mvnVer}-bin.tar.gz
echo export PATH=~/apache-maven-${mvnVer}/bin:$PATH >> ~/.bashrc

git clone "${alluxioGit}"
echo export ALLUXIO_HOME=~/alluxio >> ~/.bashrc
source ~/.bashrc

cd alluxio
mvn -T 2C clean install -DskipTests -Dmaven.javadoc.skip=true -Dfindbugs.skip=true -Dcheckstyle.skip=true -Dlicense.skip=true
