#!/bin/sh

# user enable to run script :: lfs

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ {✗}ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ {✓ }SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 


dir_toolchain="./build/toolchain"
dir_toolchain_config="./config/toolchain.list"
dir_toolchain_log="/home/lfs/logs"

status=0

#
# main
#
printf "\033[36m[ {✓ }SUCCESS ]\033[0m Step 1 - building the toolchain\n"

#
# Preparing the build
#
printf "\033[36m[ {✓ }SUCCESS ]\033[0m checking for file requirements...\n"

for line in `cat $dir_toolchain_config`
do
	printf "\t%-20s%-10s" "$(echo $line | cut -d'-' -f 1)" "$(echo $line | cut -d'-' -f 2)"
	if [ -f "$(echo $dir_toolchain/$line.sh)" ]; then
		printf "\033[32m ✓\033[0m\n"
	else
		printf "\033[31m ✗\033[0m\n"
		status=1
	fi
done

if [ $status -eq 1 ]; then
	printf "\033[31m[ {✗ }ERROR ]\033[0m failed to retrieve all toolchain files scripts\n"
	exit $status
fi

# TODO add an exit for log dir
mkdir -p $dir_toolchain_log													&& \
	printf "\033[32m[ {✓ }SUCCESS ]\033[0m log directory created\n"				|| \
	printf "\033[31m[ {✓ }SUCCESS ]\033[0m failed to create log directory\n"

#
# Build the system
#
printf "\033[36m[ {✓ }SUCCESS ]\033[0m ready to build toolchain\n"

for line in `cat $dir_toolchain_config`
do
	build_file=$(echo $dir_toolchain/$line.sh)
	printf "\033[36m[ {✓ }SUCCESS ]\033[0m running %-30s" "$build_file"
	sh $build_file "$(echo $LFS)/sources" "$dir_toolchain_log"
	status=$?
	if [ $status -eq 0 ]; then	
		printf "\033[32m ✓✓✓\033[0m\n"
	else
		printf "\033[31m ✗✗✗ (%d)\033[0m\n" "$status"
		exit $status
	fi
done
