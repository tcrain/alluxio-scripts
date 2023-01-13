# Scripts to launch and build Alluxio cluster

1. Launch nodes
- Edit script `launch-multi-cluster-instance-set.sh` to set the number and types of nodes
2. Run scripts
- `./run-scripts-multiple.sh {path to alluxio} {branch} {list of cluster ids}`, e.g. `./run-scripts-multiple.sh ../../alluxio master "c1 c2"`
3. Launch alluxio
- `./cross-cluster/start-clusters.sh {list of cluster ids} {start cross cluster master} {format clusters} {create mounts}`, e.g. `./cross-cluster/start-clusters.sh "c1 c2" 1 1`

# After modifications
1. To rebuild alluxio after local modifications
- `./build-multiple.sh {path to alluxio} {branch} {cluster ids} {build alluxio} {build benches} {format}`
2. To copy configuration files after change (alluxio-site.properties, etc..)
- `./copy-conf-files-multi-cluster.sh {list of cluster ids} {start cross cluster master}`
3. To get cluster ips
- `./get-ips.sh {cluster id}`