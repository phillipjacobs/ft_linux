#!/bin/bash

# user enable to run script :: root

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ {✗}ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ {✓}SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

# When logged in as user  root, making a single mistake can
# damage or destroy a system. Therefore, we recommend building
# the packages in this chapter as an unprivileged user.
groupadd lfs										|| exit 1
useradd -s /bin/bash -g lfs -m -k /dev/null lfs		|| exit 1

# give lfs a password
passwd lfs

# Grant  lfs full access to $LFS/tools by making  lfs the directory owner:
chown -v lfs $LFS/tools								|| exit 1

# If a separate working directory was created as suggested, give user lfs
# ownership of this directory:
chown -v lfs $LFS/sources

printf "\n\n\033[32m[ {✓}SUCCESS ] Now run : su - lfs\033[0m\n"


