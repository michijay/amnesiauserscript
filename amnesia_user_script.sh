#!/bin/bash

# AmnesiaUserScript - Create an amnesia user with ramdisk-home
# Author: Michael Janssen <m.janssen@lyrah.net>
# License: GPLv3
# Version: 1.1

# configuration
# name of the amnesia user
A_USER="user1"
# size of the home in GB
A_SIZE="1"
A_HOME="/media/ram_home/$A_USER"

echo ""
echo "▞▀▖             ▗    ▌ ▌         ▞▀▖      ▗    ▐  "
echo "▙▄▌▛▚▀▖▛▀▖▞▀▖▞▀▘▄ ▝▀▖▌ ▌▞▀▘▞▀▖▙▀▖▚▄ ▞▀▖▙▀▖▄ ▛▀▖▜▀ "
echo "▌ ▌▌▐ ▌▌ ▌▛▀ ▝▀▖▐ ▞▀▌▌ ▌▝▀▖▛▀ ▌  ▖ ▌▌ ▖▌  ▐ ▙▄▘▐ ▖"
echo "▘ ▘▘▝ ▘▘ ▘▝▀▘▀▀ ▀▘▝▀▘▝▀ ▀▀ ▝▀▘▘  ▝▀ ▝▀ ▘  ▀▘▌   ▀ "
echo "                                             Version : "$VERSION""
echo " +-+-+-+-+-+-+-+ +-+-+-+-+ +-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+"
echo " |A|m|n|e|s|i|a| |u|s|e|r| |w|i|t|h| |R|a|m|d|i|s|k|-|H|o|m|e|"
echo " +-+-+-+-+-+-+-+ +-+-+-+-+ +-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+"

# ensure script is running with root privileges
if [[ $EUID -ne 0 ]]
then
	echo "Error: This script must be run as root (or use sudo)."
	exit 1
fi

# check if the user exist
if id -u "$A_USER" >/dev/null 2>&1
then
	echo "User $A_USER already exists."
else
	echo "User $A_USER does not exist. Creating it..."
	useradd -d "$A_HOME" -s /bin/bash "$A_USER"
	echo "$A_USER:$A_USER" | chpasswd
	echo "User created and password set to username."
fi

# mount and cleanup
if mountpoint -q "$A_HOME"
then
	echo "RAM-home is currently mounted. Cleaning up..."
	# kill user processes to allow unmounting
	pkill -u "$A_USER"
	sleep 1
    
	umount -l "$A_HOME"
	echo "RAM-home unmounted and data cleared."
else
	echo "Preparing RAM-home at: $A_HOME (Size: ${A_SIZE}GB)..."

	# create mountpoint directory
	mkdir -p "$A_HOME"
	mount -t tmpfs -o size="${A_SIZE}G",mode=0700,uid="$A_USER",gid="$A_USER" tmpfs "$A_HOME"

	echo "Copying skeleton files from /etc/skel..."
	cp -rT /etc/skel/ "$A_HOME"
	chown -R "$A_USER":"$A_USER" "$A_HOME"
	echo "Setup complete. User $A_USER can now log in."
fi
