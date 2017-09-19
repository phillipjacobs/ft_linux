#!/bin/bash

# user enable to run script :: root

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ {✗}ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ {✓}SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

mkdir -pv $LFS							|| exit 1
mount -v -t ext4 /dev/sdb2 $LFS			|| exit 1

mkdir -pv $LFS/boot						|| exit 1
mount -v -t ext4 /dev/sdb3 $LFS/boot	|| exit 1

/sbin/swapon -v /dev/sdb4				|| exit 1
