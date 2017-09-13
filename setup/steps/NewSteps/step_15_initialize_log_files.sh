#!/bin/sh

# user enable to run script :: "root:"

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ { ✗ }ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ { ✓ }SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

# Initialize the log files and give them proper permissions:
touch /var/log/{btmp,lastlog,faillog,wtmp}						|| exit 1
chgrp -v utmp /var/log/lastlog									|| exit 1
chmod -v 664  /var/log/lastlog									|| exit 1
chmod -v 600  /var/log/btmp										|| exit 1

printf "\033[32m[ { ✓ }SUCCESS ] Now time for the second most scary part.\033[0m\n"
