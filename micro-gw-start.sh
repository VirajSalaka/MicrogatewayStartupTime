#!/bin/bash
script_dir=$(dirname "$0")
heap_size="512m"
#todo: set as parameter
micro_gw_version="3.0.1-rc3"
cpus="0.5"

sudo docker kill $(sudo docker ps -a | grep vsalaka/wso2micro-gw:$micro_gw_version | awk '{print $1}')
sudo docker rm $(sudo docker ps -a | grep vsalaka/wso2micro-gw:$micro_gw_version | awk '{print $1}')

export JAVA_OPTS="-Xms${heap_size} -Xmx${heap_size}"
(
    SECONDS=0
    sudo docker run -d -v ${PWD}:/home/exec/ -p 9096:9096 -p 9095:9095 -p 9090:9090 -e project="mgwTest" --name="microgw" --cpus=${cpus} vsalaka/wso2micro-gw:${micro_gw_version}
)

n=0
until [ $n -ge 60 ]; do
    (nc -zv localhost 9095) && (nc -zv localhost 9090) && (nc -zv localhost 9096) && break
    n=$(($n + 1))
    sleep 1
done
echo "Startup-time for docker start is "
echo $SECONDS
sleep 1
exit $exit_status