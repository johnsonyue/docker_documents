#!/bin/bash

#usage.  
if [ $# != 2 ]; then
	echo "usage: $0 image_list save_path"
	exit
fi

image_list=$1
save_path=$2

#check whether the image_list exsists
if [ ! -f $image_list ]; then
	echo "$image_list does not exist"
	exit
fi

#see if docker is running.
res=`/usr/bin/pgrep docker`
if [ "$res" == "" ]; then
        echo "docker is not running, restart docker and try again."
	exit
fi

cat $image_list | while read strline; do
	pseudo_name=` echo $strline | sed "s/\//#/" `
	echo "docker save -o $save_path/$pseudo_name.tar $strline"
	docker save -o $save_path/$pseudo_name.tar $strline
	echo
done
