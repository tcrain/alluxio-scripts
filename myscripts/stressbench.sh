

~/alluxio/bin/alluxio runClass alluxio.stress.cli.client.StressClientIOBench --operation ReadByteBuffer --file-size 1m --buffer-size 512k --warmup 30s --duration 30s --threads 4

~/alluxio/bin/alluxio runClass alluxio.stress.cli.client.StressClientIOBench --operation Write --base alluxio://localhost:19998/stress-client-io-base --write-num-workers 1 --file-size 100kb --threads 4 --warmup 30s --duration 30s

~/alluxio/bin/alluxio runClass alluxio.stress.cli.StressMasterBench --operation CreateDir --warmup 5s --duration 100s --target-throughput 1000000 --fixed-count 100

~/alluxio/bin/alluxio runClass alluxio.stress.cli.StressMasterBench --operation CreateFile --warmup 5s --duration 10s --target-throughput 1000000 --fixed-count 10

~/alluxio/bin/alluxio runClass alluxio.stress.cli.StressMasterBench --operation CreateFile --warmup 5s --duration 10000s --target-throughput 1000000 --fixed-count 2000000 --threads 300

~/alluxio/bin/alluxio runClass alluxio.stress.cli.StressMasterBench --operation ListDir --warmup 5s --duration 10s --target-throughput 1000000 --fixed-count 10

~/alluxio/bin/alluxio runClass alluxio.stress.cli.StressMasterBench --operation GetFileStatus --warmup 5s --duration 10s --target-throughput 1000000 --fixed-count 10000 --threads 10

~/alluxio/bin/alluxio runClass alluxio.stress.cli.StressMasterBench --operation GetFileStatus --warmup 5s --duration 10s --target-throughput 1000000 --fixed-count 2000000 --threads 300

mvn clean verify -Dcheckstyle.skip=true -Dlicense.skip -Dfindbugs.skip=true -DskipTests



java -jar target/benchmarks.jar InodeBenchRead -f 1 -t 16 -gc true -p mType=rocksCache -p mDepth=10 -p mFileCount=1000 -p mRocksConfig=baseConfig -p mSingleFile=false -p mUseZipf=false -prof async:"event=alloc;output=tree;sig=true;rawCommand=total"



mvn -DskipTests package -pl microbench -Dcheckstyle.skip=true -Dlicense.skip=true -Dfindbugs.skip=true

https://github.com/jvm-profiling-tools/async-profiler/blob/v2.8/src/arguments.cpp#L52

-agentpath:/home/centos/YourKit-JavaProfiler-2022.3/bin/linux-x86-64/libyjpagent.so=delay=10000,listen=localhost


java -jar target/benchmarks.jar FileSystemBench -p mServerType=STANDALONE -p mNumGrpcChannels=1  -p mNumConcurrentCalls=1 -p mServerPort=34795 -p mServerIpAddress=172.31.3.138 -t 1 -f 1 -prof async:"event=cpu;output=flamegraph;sig=true;rawCommand=total"

java -jar target/benchmarks.jar FileSystemBench -p mServerType=STANDALONE  -p mServerPort=33065 -p mServerIpAddress=172.31.3.138 -t 8 -f 1 -prof async:"event=cpu;output=tree;sig=true;rawCommand=total"

java -cp target/benchmarks.jar alluxio.fsmaster.FileSystemBase -s ALLUXIO_GRPC_SERVER

java -cp target/benchmarks.jar alluxio.fsmaster.FileSystemBase -s BASIC_GRPC_SERVER

~/git/alluxio/bin/alluxio runClass alluxio.stress.cli.StressMasterBench -debug  --operation GetFileStatus --warmup 5s --target-throughput 1000000 --fixed-count 1000 --duration 1500s

java -jar microbench/target/benchmarks.jar fileInvalidationBench -p mDepth=10 -p mWidth=1 -p mDistribution=ZIPF -p mFileCount=1000 -p mInvalCount=10000 -p mInvalDist=UNIFORM -p mCacheSize=100000 -p mCheckSync=50 -p mDirSync=1 -p mFileWeight=0 -f 1 -i 5 -w 10 -wi 1 -r 20 -t 8 -prof async:"libPath=/Users/tylercrain/Downloads/async-profiler-2.8-macos/build/libasyncProfiler.dylib;event=cpu;output=flamegraph;sig=true;rawCommand=total"