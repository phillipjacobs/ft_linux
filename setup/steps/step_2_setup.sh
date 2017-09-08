#!/bin/bash

#
# Run the following script as root
#

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[  ERROR  ] LFS variable not present, export it...\033[0m\n"
	exit 1
else
	printf "\033[32m[  INFOS  ] LFS variable retrieved\033[0m\n"
fi 

mkdir -v $LFS/tools							|| exit 1
ln -sv $LFS/tools /							|| exit 1

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

passwd lfs

chown -v lfs $LFS/tools						|| exit 1
chown -v lfs $LFS/sources					|| exit 1

echo "exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash" > /home/lfs/.bash_profile

echo "set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH" > /home/lfs/.bashrc

chown -v lfs:lfs /home/lfs/.bash_profile	|| exit 1
chown -v lfs:lfs /home/lfs/.bashrc			|| exit 1

chown -R lfs:lfs /mnt/lfs/ft_linux			|| exit 1

printf "\033[32m[  INFOS  ] switch to LFS user\033[0m\n"
