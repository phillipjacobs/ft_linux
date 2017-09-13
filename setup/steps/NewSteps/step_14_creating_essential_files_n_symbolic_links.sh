#!/bin/sh

# user enable to run script :: i have no name

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ { ✗ }ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ { ✓ }SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

# Some programs use hard-wired paths to programs which do not exist yet.
# In order to satisfy these programs, create a number of symbolic links
# which will be replaced by real files throughout the course of this
# chapter after the software has been installed:
ln -sv /tools/bin/{bash,cat,dd,echo,ln,pwd,rm,stty} /bin					|| exit 1
ln -sv /tools/bin/{install,perl} /usr/bin									|| exit 1
ln -sv /tools/lib/libgcc_s.so{,.1} /usr/lib									|| exit 1
ln -sv /tools/lib/libstdc++.{a,so{,.6}} /usr/lib							|| exit 1
sed 's/tools/usr/' /tools/lib/libstdc++.la > /usr/lib/libstdc++.la			|| exit 1
ln -sv bash /bin/sh															|| exit 1


# To satisfy utilities that expect the presence of /etc/mtab,
# create the following symbolic link
ln -sv /proc/self/mounts /etc/mtab											|| exit 1

# In order for user root to be able to login and for the name “root”
# to be recognized, there must be relevant entries in the /etc/passwd
# and /etc/group files.

# Create the /etc/passwd file by running the following command:

echo "
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
" > /etc/passwd																|| exit 1

# The actual password for root (the “x” used here is just a
# placeholder) will be set later

# Create the /etc/group file by running the following command:
echo "
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
systemd-journal:x:23:
input:x:24:
mail:x:34:
nogroup:x:99:
users:x:999:
" > /etc/group																|| exit 1

# To remove the “I have no name!” prompt, start a new shell.
# Since a full Glibc was installed in Chapter 5 and the /etc/passwd
# and /etc/group files have been created, user name and group name
# resolution will now work:
printf "\033[32m[ { ✓ }SUCCESS ] Now run : \033[34mexec /tools/bin/bash --login +h\033[0m\n"

