#!/bin/bash

# user enable to run script :: root

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ {✗}ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ {✓}SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

# Create the required directory by running the following as root
mkdir -v $LFS/tools					|| exit 1

# The next step is to create a /tools symlink on the host system.
# This will point to the newly-created directory on the LFS partition.
ln -sv $LFS/tools /					|| exit 1
