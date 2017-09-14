#!/bin/sh

# user enable to run script :: root:

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ { ✗ }ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ { ✓ }SUCCESS ] LFS variable was set successfully\033[0m\n"
fi


# Intro
# It is time to make the LFS system bootable. This chapter discusses
# creating an fstab file, building a kernel for the new LFS system,
# and installing the GRUB boot loader so that the LFS system can be
# selected for booting at startup


# Creating the /etc/fstab File

# Create a new file systems table like this:

echo "
# Begin /etc/fstab
# file system	mount-point	type		options				dump fsck
#															order

/dev/sdb1		/			ext4		defaults			1		1
/dev/sdb4		swap		swap		pri=1				0		0
proc			/proc		proc		nosuid,noexec,nodev 0		0
sysfs			/sys		sysfs		nosuid,noexec,nodev 0		0
devpts			/dev/pts	devpts		gid=5,mode=620		0		0
tmpfs			/run		tmpfs		defaults			0		0
devtmpfs		/dev		devtmpfs	mode=0755,nosuid	0		0

# End /etc/fstab
" > /etc/fstab


printf "\033[32m[ { ✓ }SUCCESS ] \033[0m\n"
