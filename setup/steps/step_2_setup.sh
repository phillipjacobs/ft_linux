#!/bin/bash

#
# Run the following script as root
#

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ {-}ERROR ] LFS variable not present, export it...\033[0m\n"
	exit 1
else
	printf "\033[32m[ {+}SUCCESS ] LFS variable retrieved\033[0m\n"
fi

mkdir -v $LFS/tools							|| exit 1
ln -sv $LFS/tools /							|| exit 1

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

passwd lfs

chown -v lfs $LFS/tools						|| exit 1
chown -v lfs $LFS/sources					|| exit 1

mkdir -v $LFS/ft_linux						|| exit 1
chown -R lfs:lfs /mnt/lfs/ft_linux			|| exit 1

printf "\033[32m[ {+}SUCCESS ] Now switch to lfs ( su - lfs )\033[0m\n"
