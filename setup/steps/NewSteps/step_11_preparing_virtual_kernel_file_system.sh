#!/bin/sh

# user enable to run script :: root

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ { ✗ }ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ { ✓ }SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

# Various file systems exported by the kernel are used to communicate
# to and from the kernel itself. These file systems are virtual in that
# no disk space is used for them. The content of the file systems
# resides in memory.


# Begin by creating directories onto which the file systems will be
# mounted:
mkdir -pv $LFS/{dev,proc,sys,run}							|| return


# Creating Initial Device Nodes

# When the kernel boots the system, it requires the presence of a
# few device nodes, in particular the console and null devices.
# The device nodes must be created on the hard disk so that they
# are available before udevd has been started, and additionally when
# Linux is started with  init=/bin/bash.
# Create the devices by running the following commands:
mknod -m 600 $LFS/dev/console c 5 1							|| return
mknod -m 666 $LFS/dev/null c 1 3							|| return

# Mounting and Populating /dev

# bind mount is a special type of mount that allows you to create a
# mirror of a directory or mount point to some other location.
# Use the following command to achieve this:
mount -v --bind /dev $LFS/dev								|| return

# Mounting Virtual Kernel File Systems
mount -vt devpts devpts $LFS/dev/pts -o gid=5,mode=620		|| return
mount -vt proc proc $LFS/proc								|| return
mount -vt sysfs sysfs $LFS/sys								|| return
mount -vt tmpfs tmpfs $LFS/run								|| return

# In some host systems, /dev/shm is a symbolic link to /run/shm.
# The /run tmpfs was mounted above so in this case only, a directory
# needs to be created.
if [ -h $LFS/dev/shm ]; then
  mkdir -pv $LFS/$(readlink $LFS/dev/shm)					|| return
fi



