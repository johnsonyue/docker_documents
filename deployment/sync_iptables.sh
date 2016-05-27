if [ `id -u` -ne 0 ]; then
	echo 'you must be root to run this script.'
	exit
fi

if [ $# != 1 ]; then
	echo "usage: $0 file"
	exit
fi

file="iptables.save"

is_nat=0
is_filter=0
is_chain=0
is_container=0
cat /dev/null > nat
iptables-save > temp_iptables

while read strline; do
	[ "$strline" == "" ] && continue;
	[ "`echo "$strline" | grep -w "*nat"`" ] && is_nat=1;
	[ "`echo "$strline" | grep -w "*filter"`" ] && is_filter=1;
	[ $is_nat == "1" -o $is_filter == "1" ] && is_chain=1;
	[ $is_chain == "1" -a "`echo "$strline" | grep "#"`" ] && is_container=1;
	[ "`echo "$strline" | grep -i -w "COMMIT"`" ] && is_nat=0 && is_filter=0 && is_chain=0 && is_container=0;

	if [ $is_container == "1" -a ! "`echo "$strline" | grep "#"`" ]; then 
		line=$strline;
		str=`echo ${line//\-/\\\-}`;
		str=`echo ${str//\//\\\/}`;
		sed -i "/$str/d" temp_iptables;
	fi

	[ $is_nat == "1" -a $is_container == "1" ] && echo $strline >> nat;
done < $file;

cat /dev/null > temp_file
#find insertion point.
is_nat=0
while read -r strline; do
	[ "`echo "$strline" | grep -w "*nat"`" ] && is_nat=1;
	[ $is_nat == "1" -a "`echo "$strline" | grep -i -w "COMMIT"`" ] && is_nat=0 && cat nat >> temp_file;
	echo "$strline" >> temp_file;
done < temp_iptables;

rm nat
rm temp_iptables
mv temp_file $file
