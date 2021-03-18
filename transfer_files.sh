#!/bin/bash

echo "enter port"
read port

echo "send? y/n"
read send

echo "encrypt? y/n"
read encrypt

if [ $send = "y" ]
then
	while ! [ -d "transfer_files" ]
	do
		mkdir transfer_files
		echo "place files to be sent in the 'transfer_files' directory..."
		read
	done

	echo "Enter ipv4 address"
	read address

	if [ $encrypt = "y" ]
	then
		echo "encryption_key:"
		read encryption_key
		tar -czvf - transfer_files | gpg --passphrase $encryption_key --batch --quiet --yes -ca | pv | netcat $address $port
	else
		tar -czvf - transfer_files | pv | netcat $address $port
	fi
	
else
	file_suffix=0

	# Ensure target filename unique
	while [ -d "received$file_suffix" ] || [ -f "received$file_suffix.tar.gz" ] || [ -f "received$file_suffix.tar.gz.asc" ]
	do
		file_suffix=$(($file_suffix+1))
	done

	if [ $encrypt = "y" ]
	then
		echo "decrypt? y/n"
		read decrypt

		if [ $decrypt = "y" ]
		then
			echo "decryption_key: "
			read decryption_key

			# save key temporarily and load into gpg
			echo $decryption_key > "keyfile"
			gpg --import "keyfile"
			rm "keyfile"

			echo "receive compressed? y/n"
			read compression

			if [ $compression = "n" ]
			then
				mkdir "received$file_suffix"
				cd "received$file_suffix"
				netcat -l -p $port | pv | gpg --decrypt - | tar -xzvf -
			else
				netcat -l -p $port | pv | gpg --decrypt - > "received$file_suffix.tar.gz"
			fi
		fi
	fi

	if [ $encrypt = "n" ] || [ $encrypt = "y" ] && [ $decrypt = "n" ]
	then
		if [ $decrypt = "n" ]
		then
			echo "receive compressed? y/n"
			read compression
		else
			compression="n"
		fi

		if [ $compression = "n" ]
		then
			mkdir "received$file_suffix"
			cd "received$file_suffix"
			netcat -l -p $port | pv | tar -xzvf -
		else
			netcat -l -p $port | pv > "received$file_suffix.tar.gz"
		fi
	fi
fi
