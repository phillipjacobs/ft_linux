#!/bin/bash

# user enable to run script :: root

# ✗✓
if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ { ✗ }ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ { ✓ }SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

mkdir -pv $LFS/sources		|| exit 1
chmod -v a+wt $LFS/sources	|| exit 1 # Making Writable and Sticky

wget -q --show-progress	--input-file=resources/wget-list --continue --directory-prefix=$LFS/sources

printf "\033[36[m[ { ✓ }SUCCESS ]\033[0m\n"

# wget list :
# http://www.linuxfromscratch.org/lfs/downloads/stable/wget-list
#
# md5sum list :
# http://www.linuxfromscratch.org/lfs/downloads/stable/md5sums
#
#
# you can download these by putting the command "wget" infron of the link
# followed by a space
#
# If you follow this tutorial exactly then you going to want to download
# that files in a folder called resources
