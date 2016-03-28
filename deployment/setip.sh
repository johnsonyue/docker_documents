#!/bin/bash

if [ `id -u` -ne 0 ]; then
	echo 'you must be root to run this script.'
	exit
fi

if [ $# != 5 ]; then
	echo "usage: $0 container_id veth_name ipaddr netmask gateway"
	exit
fi

container_id=$1
veth_name=$2
ipaddr=$3
netmask=$4
gateway=$5

#1. get container pid.
pid=`docker inspect -f "{{.State.Pid}}" $container_id`

#2. create a link where /var/run/netns(container) points to /proc/$pid/ns/net(host).
mkdir -p /var/run/netns
find -L /var/run/netns -type l -delete #delete corrupted link.
ln -s /proc/$pid/ns/net /var/run/netns/$pid

#3. create peer veth.
ip link add $veth_name type veth peer name eth_temp

#4. bind host end veth to docker0 and set it up.
brctl addif docker0 $veth_name
ip link set $veth_name up

#5. set netns for container end veth and make configurations.
ip link set eth_temp netns $pid
ip netns exec $pid ip link set dev eth_temp name eth0
ip netns exec $pid ip link set eth0 up
ip netns exec $pid ip addr add $ipaddr/$netmask dev eth0
ip netns exec $pid ip route add default via $gateway

