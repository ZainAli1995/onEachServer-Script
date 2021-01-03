#!/bin/bash

Usage(){

        echo "Usage: ./run-everywhere.sh [-s] [SERVERS...] [-c] COMMAND
              Executes COMMAND as a single command on every server.
              -s speficy the servers on which to run the command
              -c specify the command to run"
        exit 1
}

allServers(){
	
	local ALL_SERVERS=$1
	echo "Value of local variable: $ALL_SERVERS"
	
	touch /root/bash_tutorial/servers/custom_servers.txt
	
	if [[ $ALL_SERVERS == 'true' ]]
	then
		FILE='/root/bash_tutorial/servers/servers.txt'
		
		local COMMAND=$2
	else
		LIST_SERVERS=$2
		
		echo "The list of servers: $LIST_SERVERS"
		
		for i in $(echo "$LIST_SERVERS" | sed "s/,/ /g")

		do
			echo $i >> '/root/bash_tutorial/servers/custom_servers.txt'
		done
		
		FILE='/root/bash_tutorial/servers/custom_servers.txt'
		
		local COMMAND=$3
	fi	

	for SERVER in `cat $FILE`
	do
		echo "executing command on server: $SERVER"
		echo "===================================="
		ssh -o ConnectTimeout=2 ${SERVER} ${COMMAND} 2> /dev/null
		
		if [[ $? -eq 1 ]]
		then
			echo "ssh connection to $SERVER timed out"
		fi
	done
	
	rm /root/bash_tutorial/servers/custom_servers.txt	
	
	if [[ $# -eq 0 ]]
	then
		exit 0
	fi
}

#Script needs to given at least three arguments

if [[ $# -lt 3 ]]
then
	Usage
fi

while getopts s:c: OPTIONS
do
	case $OPTIONS in
	
	s) SERVERS=$OPTARG
	   ;;
	
	c) COMMAND=$OPTARG
	   ;;
	
	?) Usage
	   ;;
	
	esac
done

#Shift the arguments provided above

shift $(( OPTIND -1 ))

#Check if the servers arguments is emtpy

if [[ $SERVERS == -* ]]
then
	Usage
fi

COUNTER=0

if [[ $SERVERS == 'all' ]]
then
	allServers true "${COMMAND}"
else
	allServers false "${SERVERS}" "${COMMAND}"
fi
