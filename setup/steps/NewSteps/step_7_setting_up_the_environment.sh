#!/bin/bash

# user enable to run script :: lfs

# create a new .bash_profile
echo "
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
" > ~/.bash_profile

# The new instance of the shell is a  non-login shell, which does
# t read the  /etc/profile or .bash_profile files, but rather reads
# the  .bashrc file instead. Create the .bashrc file now

echo "
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH
" > ~/.bashrc

printf "\n\n\033[32m[ {✓}SUCCESS ] Now run : source ~/.bash_profile\033[0m\n"

