#!/bin/bash 

file=iptables.save #don't use the name "temp".
log_file=docker.log

#usage.  
if [ $# != 2 ]; then
	echo "usage: $0 create/start/stop/rm/pause/unpause config_file"
	exit
fi

operation=$1
config=$2

#check if the operation exists.
if [ "$operation" != "create" -a "$operation" != "start" -a "$operation" != "stop" -a "$operation" != "rm" -a "$operation" != "pause" -a "$operation" != "unpause" ]; then
	echo "no such operation, only create/start/stop/rm allowed"
	exit
fi

#check whether the config_file exsists
if [ ! -f $config ]; then
	echo "$config does not exist"
	exit
fi

#see if docker is running.
res=`/usr/bin/pgrep docker`
if [ "$res" == "" ]; then
        echo "docker is not running, restart docker and try again."
	exit
fi

#sync_iptables.
if [ -e "./iptables.save" ]; then
	echo "./sync_iptables.sh $file";
	./sync_iptables.sh $file;
	echo
fi

#create container(s).
if [ "$operation" == "create" ]; then
	cat $config | while read strline; do
		#ignore comments.
		[ "`echo $strline | grep \#`" -o ! -n "$strline" ] && continue
		read -a arr <<< $strline
		name=${arr[0]}
		net=${arr[1]}
		pub=${arr[2]}
		port=${arr[3]}
		vol=${arr[4]}
		img=${arr[5]}
		cmd=${arr[6]}
		
		vol_opt=""
		arr=${vol//,/ } #replace ',' with ' '.
		for e in $arr ; do
			vol_opt=$vol_opt"-v $e "	
		done
		
		net_opt="--net=$net"

		[ "$vol" == "-" ] && vol_opt=""
		[ "$net" == "-" ] && net_opt=""
		
		#check validity.
		state=`docker inspect -f "{{.State.Status}}" $name 2>> /dev/null`
		if [ "$state" == "stopped" -o "$state" == "running" -o "$state" == "paused" ]; then
			echo "you can only create a non-existng container, use rm first if you want replacement." 
			continue
		fi
		
		#create a container.
		docker run -itd --cap-add ALL $net_opt --name=$name $vol_opt $img $cmd > /dev/null
		echo "docker run -id --net=$net --name=$name $vol_opt $img $cmd"
		
		#get loc ip.
		container_id=`docker inspect -f {{.Id}} $name | cut -b 1-12`
		PID=`docker inspect -f "{{.State.Pid}}" $name`
		docker_exec="nsenter --target $PID --mount --uts --ipc --net --pid -- /bin/bash -c"
		loc=`$docker_exec "ifconfig eth1" | sed -n 2p | awk -F " " '{print $2}' | cut -d ':' -f2`
		
		#iptables.
		if [ ! -e ./iptables.save ]; then
			iptables-save > iptables.save
		fi

		#map ip. 
		[ "$pub" != "-" -a "$port" != "-" ] && echo "./mapip.sh $loc $pub $port $name $file" && ./mapip.sh $loc $pub $port $name $file 
		#[ "$pub" != "-" -a "$port" != "" ]  && echo "./mapip.sh $loc $pub $port $name $file" 
		
		#logging.
		echo `date`: container $name created with id $container_id . >> $log_file
		
		#delimeter.
		echo
	done
fi

#start container(s).
if [ "$operation" == "start" ]; then
	cat $config | while read strline; do
		#ignore comments.
		[ "`echo $strline | grep \#`" -o ! -n "$strline" ] && continue
		read -a arr <<< $strline
		name=${arr[0]}
		pub=${arr[2]}
		port=${arr[3]}
		cmd=${arr[6]}

		
		#check validity.
		state=`docker inspect -f "{{.State.Status}}" $name`
		if [ "$state" != "exited" ]; then
			echo "you can only start a exited container."
			continue
		fi

		#start the container.
		docker start $name
		echo "docker start $name"

		#get loc ip.
		container_id=`docker inspect -f {{.Id}} $name | cut -b 1-12`
		PID=`docker inspect -f "{{.State.Pid}}" $name`
		docker_exec="nsenter --target $PID --mount --uts --ipc --net --pid -- /bin/bash -c"
		loc=`$docker_exec "ifconfig eth1" | sed -n 2p | awk -F " " '{print $2}' | cut -d ':' -f2`

		#map ip. 
		[ "$pub" != "-" -a "$port" != "-" ] && echo "./mapip.sh $loc $pub $port $name $file" && ./mapip.sh $loc $pub $port $name $file 

		#restart services.(deleted bc bash will take over stdin and hung forever.
		#docker exec $container_id $cmd

		#logging.
		echo `date`: container $name started. >> $log_file

		#delimeter.
		echo
	done
fi


#rm/stop container(s).
if [ "$operation" == "rm" -o "$operation" == "stop" ]; then
	cat $config | while read strline; do
		#ignore comments.
		[ "`echo $strline | grep \#`" -o ! -n "$strline" ] && continue
		read -a arr <<< $strline
		name=${arr[0]}

		#check validity.
		state=`docker inspect -f "{{.State.Status}}" $name`
		if [ "$operation" == "stop" -a "$state" != "running" ]; then
			echo "you can only stop a running container."
			continue
		fi

		echo "docker stop $name" && docker stop $name 

		#logging.
		echo `date`: container $name stoped. >> $log_file
		
		if [ "$operation" == "rm" ]; then
			echo "docker rm $name"
			docker rm $name
			
			#logging.
			echo `date`: container $name removed. >> $log_file

			#remember to restore the iptables.
			echo "restoring iptables"
			mkdir -p backup
			cp $file backup/`date "+%y-%m-%d-%H:%M:%S"`-$file
			cat /dev/null > temp

			is_rm=0
			cat $file | while read strline; do
				[ "`echo $strline | grep -w \#$name`" ] && is_rm=1 && continue
				[ "`echo $strline | grep \#`" -o "`echo $strline | grep -wi COMMIT`" ] && [ $is_rm -eq 1 ] && is_rm=0
				[ $is_rm -eq 0 ] && echo $strline >> temp
			done

			mv -f temp $file
			rm -f temp
			iptables-restore $file
		fi
		
		#delimeter.
		echo
	done
fi

if [ "$operation" == "pause" -o "$operation" == "unpause" ]; then
	cat $config | while read strline; do
		#ignore comments.
		[ "`echo $strline | grep \#`" -o ! -n "$strline" ] && continue
		read -a arr <<< $strline
		name=${arr[0]}

		#check validity.
		state=`docker inspect -f "{{.State.Status}}" $name`
		if [ "$operation" == "pause" -a "$state" != "running" ]; then
			echo "you can only pause a running container."
			continue
		fi
		if [ "$operation" == "unpause" -a "$state" != "paused" ]; then
			echo "you can only unpause a paused container."
			continue
		fi

		echo "docker $operation $name" && docker $operation $name 

		#logging.
		echo `date`: container $name stoped. >> $log_file
		
		#delimeter.
		echo
	done
fi

