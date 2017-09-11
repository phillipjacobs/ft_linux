#!/bin/sh

# user enable to run script :: root

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ {✗ }ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ {✓ }SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

# It is time to enter the chroot environment to begin building
# and installing the final LFS system. As user root, run the
# following command to enter the realm that is, at the moment,
# populated with only the temporary tools

chroot "$LFS" /tools/bin/env -i \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='\u:\w\$ '              \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h

