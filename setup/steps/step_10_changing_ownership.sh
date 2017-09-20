#!/bin/sh

# user enable to run script :: root

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ {✗}ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ {✓}SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

# Change the ownership of the $LFS/tools directory to user root
# by running the following command:
chown -R root:root $LFS/tools
