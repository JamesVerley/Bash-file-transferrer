#!/bin/bash

echo "current directory '"$(pwd)"'"
echo "enter port"
read port

echo "send? yes/no"
read send

echo "encryption? yes/no"
read encrypt

if [ $send = "yes" ]
then
	while ! [ -d "transfer_files" ]
	do
		mkdir transfer_files
		echo "place files to be sent in the 'transfer_files' directory\nEnter to continue"
		read
	done

	echo "Enter address"
	read address

	if [ $encrypt = "yes" ]
	then
		echo "passphrase:"
		read passphrase
	fi

	if [ $encrypt = "yes" ]
	then
		tar -czvf - transfer_files | gpg --passphrase $passphrase --batch --quiet --yes -ca | pv | netcat $address $port
	else
		tar -czvf - transfer_files | pv | netcat $address $port
	fi
	
else


	# echo "waiting/receiving"
	file_suffix=0

	# Ensure target filename unique
	while [ -d "received$file_suffix" ] || [ -f "received$file_suffix.tar.gz" ] || [ -f "received$file_suffix.tar.gz.asc" ]
	do
		file_suffix=$(($file_suffix+1))
	done

	if [ $encrypt = "yes" ]
	then
		echo "receive encrypted? yes/no"
		read keep_encrypted

		if [ $keep_encrypted = "no" ]
		then
			echo "key:"
			read passphrase

			echo "receive compressed? yes/no"
			read compression

			if [ $compression = "no" ]
			then
				mkdir "received$file_suffix"
				cd "received$file_suffix"
				netcat -l -p $port | pv | gpg --decrypt - | tar -xzvf -
			else
				netcat -l -p $port | pv | gpg --decrypt - > "received$file_suffix.tar.gz"
			fi
		fi
	fi

	if [ $encrypt = "no" ] || [ $encrypt = "yes" ] && [ $keep_encrypted = "yes" ]
	then
		if [ $keep_encrypted = "no" ]
		then
			echo "receive compressed? yes/no"
			read compression
		else
			compression="no"
		fi

		if [ $compression = "no" ]
		then
			mkdir "received$file_suffix"
			cd "received$file_suffix"
			netcat -l -p $port | pv | tar -xzvf -
		else
			netcat -l -p $port | pv > "received$file_suffix.tar.gz"
		fi
	fi
fi
