#!/bin/bash

if [ `id -u` -ne 0 ]; then
	echo 'you must be root to run this script.'
	exit
fi

if [ $# != 5 ]; then
	echo "usage: $0 local_ip public_ip port comment file";
	exit
fi

loc_ip=$1
pub_ip=$2
port=$3
comment=$4
file=$5

#backup the original file.
mkdir -p backup
cp $file backup/`date "+%y-%m-%d-%H:%M:%S"`-$file

#contents to insert.
insert(){
	echo "#$comment" >> temp
	#parse arguments.
	arr=${port//:/ } #replace ':' with ' '.
	for e in $arr ; do
		proto=tcp
		[ `echo $e | grep udp` ] && proto=udp
		port=`echo $e | grep -o "[0-9]*"`
		
		echo "-A POSTROUTING -s $loc_ip/32 -d $loc_ip/32 -p $proto -m $proto --dport $port -j SNAT --to-source $pub_ip" >> temp
		echo "-A DOCKER -d $pub_ip ! -i docker0 -p $proto -m $proto --dport $port -j DNAT --to-destination $loc_ip:$port" >> temp
	done
}

#find insertion point.
cat /dev/null > temp
while read strline; do
	[ `echo "$strline" | grep -w "#$comment"`x != x ] && is_update=1; 
done < $file

is_insert=0
is_nat=0
while read strline; do
	if [ "$is_update" == "1" ]; then
		[ "$strline" == "#$comment" ] && is_insert=1 && insert; 
		[ `echo "$strline" | grep -i -w "COMMIT"`x != x -o "`echo "$strline" | grep -v "#$comment" | grep "#"`"x != x ] && [ "$is_insert" == "1" ] && is_insert=0;

		[ $is_insert -eq 0 ] && echo $strline >> temp;
	else
		[ `echo "$strline" | grep -w "*nat"`x != x ] && is_nat=1; 
		[ "$is_nat" == "1" ] && [ `echo $strline | grep -i -w "COMMIT"`x != x ] && insert && is_nat=0;
		echo $strline >> temp;
	fi
done < $file

#make iptables.save into effect.
mv -f temp $file 
rm -f temp
iptables-restore $file

