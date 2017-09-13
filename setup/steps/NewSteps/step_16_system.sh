#!/bin/sh

# user enable to run script :: "root:""

# directories and configuration files

dir_system="./build/system"
dir_system_config="./config/system.list"
dir_system_log="/logs"

status=0

#
# Main
#

printf "\033[36m[ { + }SUCCESS ]\033[0m Step 5 - building the system\n"

#
# Preparing the build
#

printf "\033[36m[ { + }SUCCESS ]\033[0m checking for file requirements...\n"

for line in `cat $dir_system_config`
do
	printf "\t%-20s%-10s" "$(echo $line | cut -d'-' -f 1)" "$(echo $line | cut -d'-' -f 2)"
	if [ -f "$(echo $dir_system/$line.sh)" ]; then
		printf "\033[32m ✓\033[0m\n"
	else
		printf "\033[31m ✗\033[0m\n"
		status=1
	fi
done

if [ $status -eq 1 ]; then
	printf "\033[31m[ { - }ERROR ]\033[0m failed to retrieve all system files scripts\n"
	exit $status
fi

# TODO add an exit for log dir
mkdir -p $dir_system_log													&& \
	printf "\033[32m[ { + }SUCCESS ]\033[0m log directory created\n"				|| \
	printf "\033[31m[ { + }SUCCESS ]\033[0m failed to create log directory\n"

#
# Build the system
#

printf "\033[36m[ { + }SUCCESS ]\033[0m ready to build system\n"

for line in `cat $dir_system_config`
do
	build_file=$(echo $dir_system/$line.sh)
	printf "\033[36m[ { + }SUCCESS ]\033[0m running %-20s" "$build_file"
	sh $build_file "/sources" "/logs"
	status=$?
	if [ $status -eq 0 ]; then	
		printf "\033[32m ✓✓✓\033[0m\n"
	else
		printf "\033[31m ✗✗✗ (%d)\033[0m\n" "$status"
		exit $status
	fi
done
