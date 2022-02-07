#!/bin/bash

# Variables for colour
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

# UPDATE ME !!!
AUTH_TOKEN=#authentication token used in header(base64 encoded)
URL=#graylog.url
graylog_backend_api=#graylog_backendAPI


echo -e "${green}[+] Starting Script...!${reset}"
#First call
read -p "	${yellow}Are you sure?(Y/N)${reset}" -n 1 -r
echo   
if [[ $REPLY =~ ^[Yy]$ ]]
then
	# Calling api and storing the result in a random file at /tmp/
	echo -e "${green}[+] Waiting for server response ...${reset}"
	
	file="/tmp/$(echo $RANDOM | base64 | head -c 20)"
	
	curl --output $file -s -H 'Authorization: Basic $AUTH_TOKEN' -H 'X-Requested-By: cli' -X GET --url "https://$URL/api/plugins/org.graylog.plugins.archive/cluster/archives/catalog?page=1&per_page=5000"
	# 5 Sec delay for curl to collect data and store them	
	sleep 5
	
	# check the file is saced or not
	if [[ ! -e $file ]]; then
		echo -e "${red}\t[-] Error: $file not found (Probably API failed!)${reset}"
	fi

	
	count=$(jq '.archives[].archive_id' $file | wc -l)	
	adjcount=$[$count - 1] 
	
	#Month from which we want our archives to delete 

	# Make sure you add +1 month, if you want delete logs older then 3 months use 4 months in the command below.
	last_month=$(date -d ' 4 month ago' +%Y-%m)
	
	echo -e "${green}\t[++] Total Archieves Found:${reset}${red} $adjcount ${reset}"
	echo -e "${green}\n[+] Deleteing Archives storing data of :${reset}${red} $last_month and before${reset}"
	# Secound call
	read -p "	${yellow}Are you sure?(Y/N)${reset}" -n 1 -r
	echo 
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		# archiveid and timestamp is collected form the file it self (json data we got from api)
		echo -e "${green}[+] Searching for old archives ...${reset}"
		for ((x=0;x<=$adjcount; x++));do
			archive_id=$(cat $file | jq --argjson x "$x" '.archives[$x].archive_id')
			timestamp=$(cat $file | jq --argjson x "$x" '.archives[$x].timestamp_max[0:7]')
		
			if expr "$timestamp" "<" "$last_month" >/dev/null; then
				echo -e "\tArchive Found: $archive_id/$timestamp" | sed -e 's/"//g'
				# stroing in a different file to use later without double quots
				echo $archive_id | sed -e 's/^"//' -e 's/"$//'  >> deleted_archives.txt
			fi
		done	
		# checking for file to exist
		if [[ ! -e deleted_archives.txt ]]; then
			echo -e "${red}[-] No Archives found to delete${reset}"
		else
			echo -e "${red}\n[Final Confirmation]${reset}"
			read -p "	${yellow}Are you sure you want to continue?(Y/N)${reset}" -n 1 -r
		        echo
        		if [[ $REPLY =~ ^[Yy]$ ]]; then
				echo -e "${green}[+] Deleting Archives ...!!${green}"
				while read p;do
					# API call for deletion 
					curl -s -H 'Authorization: Basic $AUTH_TOKEN' -H 'X-Requested-By: cli' -X DELETE https://$URL/api/plugins/org.graylog.plugins.archive/cluster/archives/backend/$graylog_backend_api/$p >/dev/null
				done < deleted_archives.txt

				echo -e "${green}[+] Archives has been deleted${reset}"
			else 
				# cleaning everything
				rm -rf file deleted_archives.txt
				echo -e "${red}[!!] Job Cancelled${reset}"
			fi
		fi
	else 
		# cleaning everything
		rm -rf $file
		echo -e "${red}[!!] Job Cancelled${reset}"
	
	fi
	# cleaning everything
	rm -rf $file deleted_archives.txt
else
	echo -e "${red}[!!] Job Cancelled${reset}"
fi 
