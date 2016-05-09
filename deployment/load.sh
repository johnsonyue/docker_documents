#!/bin/bash

#usage.
if [ $# != 1 ]; then
        echo "usage: $0 save_path"
        exit
fi

save_path=$1

#see if docker is running.
res=`/usr/bin/pgrep docker`
if [ "$res" == "" ]; then
        echo "docker is not running, restart docker and try again."
        exit
fi

for file in `ls $save_path`; do
        if [ "`echo $file | grep .tar`" ]; then
                echo "docker load < $save_path/$file"
                docker load < $save_path/$file
                echo
        fi

done
