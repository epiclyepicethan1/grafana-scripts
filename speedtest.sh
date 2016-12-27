#!/bin/sh
#taken from https://gist.github.com/dashbad/c13830d552223a16a0f3d2f9d746d471 and modified a bit
#NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
#NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
#NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
#This script requires speedtest-cli to function!!!!!!!!!!!!!!!!!!!!!!!

	#Store the speedtest results into a variable
	results=$(speedtest-cli --simple)
	
	#echo "$results"
	
	#Lets try to find the lines we are looking for
	while read -r line; do
		#Check if we have the line we are looking for
		if [[ $line == *"Ping"* ]]
		then
		  ping=$line
		fi
		if [[ $line == *"Download"* ]]
		then
		  download=$line
		fi
		if [[ $line == *"Upload"* ]]
		then
		  upload=$line
		fi
	done <<< "$results"
	
	echo "$ping"
	echo "$download"
	echo "$upload"
	
	#Break apart the results based on a space
	IFS=' ' read -ra arrping <<< "$ping"
	ping=${arrping[1]}
	IFS=' ' read -ra arrdownload <<< "$download"
	download=${arrdownload[1]}
	IFS=' ' read -ra arrupload <<< "$upload"
	upload=${arrupload[1]}
	
	#Convet to mbps
	download=`echo - | awk "{print $download * 1048576}"`
	upload=`echo - | awk "{print $upload * 1048576}"`
	#download=$((download * 1048576))
	#upload=$((upload * 1048576))
	
	echo "$ping"
	echo "$download"
	echo "$upload"
	
	#Write to the database
	curl -i -XPOST 'http://INFLUXDB-IP/write?db=DATABASE-NAME' --data-binary "speedtest,metric=ping value=$ping"
	curl -i -XPOST 'http://INFLUXDB-IP/write?db=DATABASE-NAME' --data-binary "speedtest,metric=download value=$download"
	curl -i -XPOST 'http://INFLUXDB-IP/write?db=DATABASE-NAME' --data-binary "speedtest,metric=upload value=$upload"
