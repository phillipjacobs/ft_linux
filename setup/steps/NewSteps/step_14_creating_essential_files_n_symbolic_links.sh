#!/bin/sh

# user enable to run script :: i have no name

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ {✗ }ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ {✓ }SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

