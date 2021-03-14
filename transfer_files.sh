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
		echo "place files to be sent in the 'transfer_files' directory"
		echo "Enter to continue"
		read
	done
	
	echo "Enter address"
	read address
	tar -czvf - transfer_files | pv | netcat $address $port
		
else
        echo "waiting/receiving"
        file_suffix=0
        while [[ -d "received"+$file_suffix+".tar.gz" ]]
        do
                file_suffix=$(($file_suffix+1))
        done
	cd "received$file_suffix"
        netcat -l -p $port | pv | tar -xzvf -
fi
