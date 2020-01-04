#!/bin/bash

case $# in
0) echo "No argument supplied.";;

1) test_date=$(mdls $1 | awk '/ContentCreationDate/ {
	if (count < 1){ 
		gsub("-","");
		gsub(":",".")
		{print $3 $4} 
		count++	
	} 
}' | sed 's/\.//1')
touch -t $test_date $1
;;

*) i=2
while [ $i -le $# ]
do
	test_date=$(mdls ${!i} | awk '/ContentCreationDate/ {
		if (count < 1){ 
			#gsub("-","");
			gsub(":",".")
			#{print $3 $4} 
			{print $3} 
			count++	
		} 
	}' | sed 's/\.//1')
	
	test_year=$(echo $test_date | awk -F "-" '{print $1}' )
	test_month=$(echo $test_date | awk -F "-" '{print $2}' )
	test_day=$(echo $test_date | awk -F "-" '{print $3}' )
	
	test_time=$(mdls ${!i} | awk '/ContentCreationDate/ {
		if (count < 1) 
			{print $4} 
			count++	
	}')
	
	test_hour=$(echo $test_time | awk -F ":" '{print $1}' )
	test_minute=$(echo $test_time | awk -F ":" '{print $2}' )
	test_second=$(echo $test_time | awk -F ":" '{print $3}' )
		
	test_hour=$(($test_hour+$1))
	if [ $test_hour -lt 0 ]
	then
		test_hour=$(($test_hour+24))
		test_day=$(($test_day-1))
		if [ $test_day -lt 1 ]
		then
			test_month=$(($test_month-1))
			while [[ ${#test_month} -lt 2 ]] ; do
			    test_month="0${test_month}"
			done
			echo $test_month
			case $test_month in
				00|0)
					test_year=$(($test_year-1))
					test_month=12
					test_day=31
					;;
				01|1|03|3|05|5|07|7|08|8|10|12)
					test_day=31
					;;
				02|2)
					test_day=28
					;;
				04|4|06|6|09|9|11)
					test_day=30
					;;
			esac
				
		fi
	elif [ $test_hour -gt 23 ]
	then 
		test_hour=$(($test_hour-24))
		test_day=$(($test_day+1))
		case $test_month in
			01|03|05|07|08|10)
				if [ $test_day -gt 31 ]
				then 
					test_day=1
					test_month=$(($test_month+1))
				fi 
				;;
			02)
				if [ $test_day -gt 28 ]
				then 
					test_day=1
					test_month=$(($test_month+1))
				fi 
				;;
			04|06|09|11)
				if [ $test_day -gt 30 ]
				then 
					test_day=1
					test_month=$(($test_month+1))
				fi 
				;;
			12)
				if [ $test_day -gt 31 ]
				then 
					test_day=1
					test_month=1
					test_year=$(($test_year+1))
				fi
				;;
			esac
	fi
	while [[ ${#test_month} -lt 2 ]] ; do
	    test_month="0${test_month}"
	done
	while [[ ${#test_day} -lt 2 ]] ; do
	    test_day="0${test_day}"
	done
	while [[ ${#test_hour} -lt 2 ]] ; do
	    test_hour="0${test_hour}"
	done
	
	test_date="${test_year}${test_month}${test_day}"
	test_date="${test_date}${test_hour}${test_minute}.${test_second}"
	
	touch -t $test_date ${!i}
	((i++))
done
;;
esac
