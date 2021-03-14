echo "current directory '"$(pwd)"'"                                                                               
echo "enter port"
read port

echo "send? yes/no"
read send

if [[ $send = 'yes' ]];
then
	while ! [[ -d "transfer_files" ]]
	do
		mkdir transfer_files
		echo "place files to be sent in the 'transfer_files' directory\nEnter to continue"
		read
	done
	
	echo "Enter address"
	read address
	tar -czvf - transfer_files | pv | netcat $address $port
		
else	
	echo "receive decompressed? yes/no"
	read compression
	
	echo "waiting/receiving"
	file_suffix=0
        while [[ -d "received"$file_suffix ]]
        do
                file_suffix=$(($file_suffix+1))
	done
	
	if ! [[ $compression = 'yes' ]]
	then
		netcat -l -p $port | pv | tar -xzvf -
	else
	        mkdir "received$file_suffix"
		cd "received$file_suffix"
		netcat -l -p $port | pv
	fi
fi
