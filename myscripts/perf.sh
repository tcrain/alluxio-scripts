set -e

sudo yum -y install perf gawk cmake
sudo yum -y group install "Development Tools"

rm -rf perf-map-agent
git clone https://github.com/jvm-profiling-tools/perf-map-agent.git
cd perf-map-agent
cmake .
make

cd ~
rm -rf FlameGraph
git clone https://github.com/brendangregg/FlameGraph.git

echo export FLAMEGRAPH_DIR=~/FlameGraph >> ~/.bashrc
echo export AGENT_HOME=~/perf-map-agent >> ~/.bashrc
source ~/.bashrc
