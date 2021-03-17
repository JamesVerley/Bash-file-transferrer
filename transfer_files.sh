#!/bin/bash

echo "current directory '"$(pwd)"'"
echo "enter port"
read port

echo "send? yes/no"
read send

echo "encrypt(ed)? yes/no"
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
	echo "receive compressed? yes/no"
	read compression

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
			echo "passphrase:"
			read passphrase
		fi
	fi

	# 1. if received compressed
	# 2. if encrypt and keep_encrypted
	# 3. if not encrypted and received compressed
	# 4. if not encrypted and received decompressed

	# 	if [ $compression = "no" ]
	# 	then
	# 		mkdir "received$file_suffix"
	# 		cd "received$file_suffix"
	# 		netcat -l -p $port | pv | tar -xzvf -
	# 	else
	# 		netcat -l -p $port | pv > "received$file_suffix.tar.gz"
	# 	fi
	# fi
fi
