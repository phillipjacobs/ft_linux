#!/bin/bash

#
# Run the following script as root
#

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ {-}ERROR  ] LFS variable not present, export it...\033[0m\n"
	exit 1
else
	printf "\033[32m[ {+}SUCCESS ] LFS variable retrieved\033[0m\n"
fi 

mkdir -pv $LFS/sources		|| exit 1
chmod -v a+wt $LFS/sources	|| exit 1 # Making Writable and Sticky

wget -q --show-progress	--input-file=resources/wget-list --continue --directory-prefix=$LFS/sources

printf "\033[36[m[ {+}SUCCESS ] If md5sum exist then continue\033[0m\n"
