# Bash-file-transferrer

## Purpose
To simplify the sending and receiving of files over a network using debian bash commands by including them in a single user-friendly script

## Usage
Run the script, enter a vacant port, and choose between

### Sending
A directory will be created for which to place the files to be sent if it doesn't already exist, prompting the user to populate it
Afterwards the user must enter the address of the recipient machine

### Receiving
A unique directory will be created and be populated with any files received

## Dependencies
apt-get install netcat pv tar
