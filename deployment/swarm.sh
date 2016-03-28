#usage.  
if [ $# != 3 ]; then
	echo "usage: $0 host_ip manage_port agent_port"
	exit
fi

host_ip=$1
manage_port=$2
agent_port=$3

#data store.
docker run \
    -ti \
    -d \
    --restart=always \
    --name shipyard-rethinkdb \
    rethinkdb

#discovery.
docker run \
    -ti \
    -d \
    -p 4001:4001 \
    -p 7001:7001 \
    --restart=always \
    --name shipyard-discovery \
    microbox/etcd -name discovery

#swarm manager
docker run \
    -ti \
    -d \
    --restart=always \
    --name shipyard-swarm-manager \
    swarm:latest \
    manage --host tcp://0.0.0.0:$manage_port etcd://$host_ip:4001

#swarm agent
docker run \
    -ti \
    -d \
    --restart=always \
    --name shipyard-swarm-agent \
    swarm:latest \
    join --addr $host_ip:$agent_port etcd://$host_ip:4001

#shipyard controller
docker run \
    -ti \
    -d \
    --restart=always \
    --name shipyard-controller \
    --link shipyard-rethinkdb:rethinkdb \
    --link shipyard-swarm-manager:swarm \
    -p 8080:8080 \
    shipyard/shipyard:latest \
    server \
    -d tcp://swarm:$manage_port
