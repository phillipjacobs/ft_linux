#!/bin/sh

# user enable to run script :: i have no name

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ {✗ }ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ {✓ }SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

# It  is  time  to  create  some  structure  in  the  LFS  file
# system.  Create  a  standard  directory  tree  by  issuing 
# the  following commands:
mkdir -pv /{bin,boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}		|| exit 1
mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}							|| exit 1
install -dv -m 0750 /root												|| exit 1
install -dv -m 1777 /tmp /var/tmp										|| exit 1
mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}						|| exit 1
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}			|| exit 1
mkdir -v  /usr/{,local/}share/{misc,terminfo,zoneinfo}					|| exit 1
mkdir -v  /usr/libexec													|| exit 1
mkdir -pv /usr/{,local/}share/man/man{1..8}								|| exit 1

case $(uname -m) in
 x86_64) mkdir -v /lib64 ;;
esac

mkdir -v /var/{log,mail,spool}											|| exit 1
ln -sv /run /var/run													|| exit 1
ln -sv /run/lock /var/lock												|| exit 1
mkdir -pv /var/{opt,cache,lib/{color,misc,locate},local}				|| exit 1
