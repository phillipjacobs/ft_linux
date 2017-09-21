#!/bin/sh

# user enable to run script :: root:

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ { ✗ }ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ { ✓ }SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

#  Using GRUB to Set Up the Boot Process

# cd /tmp																|| exit 1
# grub-mkrescue --output=grub-img.iso									|| exit 1
# xorriso -as cdrecord -v dev=/dev/cdrw blank=as_needed grub-img.iso	|| exit 1

# Install the GRUB files into /boot/grub and set up the boot track:
grub-install /dev/sdb												|| exit 1

#  Creating the GRUB Configuration File

echo '
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5
insmod ext2
set root=(hd0,3)
menuentry "GNU/Linux, Linux 4.12.7-lfs-8.1-phjacobs" {
        linux   /vmlinuz-4.12.7-lfs-8.1-phjacobs root=/dev/sda2 ro
}
' > /boot/grub/grub.cfg												|| exit 1

printf "\033[32m[ { ✓ }SUCCESS ] : Now run : echo 'The End Is coming'\033[0m\n"vmlin
