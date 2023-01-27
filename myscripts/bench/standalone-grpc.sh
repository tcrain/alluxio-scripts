
java -cp microbench/target/benchmarks.jar alluxio.fsmaster.BenchStandaloneGrpcServer -s BASIC_GRPC_SERVER -p 43539

java -Djmh.ignoreLock=true -jar microbench/target/benchmarks.jar alluxioGetStatusBench -p mServerIpAddress=172.31.15.216 -p mNumGrpcChannels=100 -p mServerPort=43539 -p mServerType=STANDALONE -t 500 -r 20

java -Djmh.ignoreLock=true -jar microbench/target/benchmarks.jar alluxioGetStatusBench -p mServerIpAddress=127.0.0.1 -p mNumGrpcChannels=3 -p mServerPort=43539 -p mServerType=STANDALONE -t 500 -r 20

sudo lsof -i -P -n
