#usage.  
if [ $# != 1 ]; then
	echo "usage: $0 host_ip"
	exit
fi

host_ip=$1

docker run \
    -d \
    -p 8500:8500 \
    -h consul \
    --name=consul \
    progrium/consul -server -bootstrap

docker run \
    -ti \
    -d \
    -p 3375:2375 \
    --restart=always \
    --name=manager \
    swarm:latest \
    manage --host tcp://0.0.0.0:2375 consul://$host_ip:8500

docker run \
    -ti \
    -d \
    --restart=always \
    --name=agent \
    swarm:latest \
    join --addr $host_ip:4375 consul://$host_ip:8500
