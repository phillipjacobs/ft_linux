#!/bin/bash

# user enable to run script :: "root:"

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ { ✗ }ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ { ✓ }SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 


pkg_source="linux-4.12.7.tar.xz"
pkg_path="/sources/linux-4.12.7.tar.xz"

pkg_name="$(basename $(tar -tf $pkg_path | head -n 1 | cut -d'/' -f 1))"

base_dir="/sources"
log_file="/logs/kernel-installation.log"

status=0

setup(){
	cd $base_dir							|| return
	cd $pkg_name							|| return
}

build(){
	#  The following command assumes an x86 architecture
	cp -v arch/x86/boot/bzImage /boot/vmlinuz-4.12.7-lfs-8.1	|| return

	# System.map is a symbol file for the kernel. It maps the function entry
	# points of every function in the kernel API, as well as the addresses
	# of the kernel data structures for the running kernel. It is used as a
	# resource when investigating kernel problems. Issue the following command
	# to install the map file:
	cp -v System.map /boot/System.map-4.12.7					|| return

	# Backup config file for future references
	cp -v .config /boot/config-4.12.7							|| return

	# Install the documentation for the Linux kernel
	install -d /usr/share/doc/linux-4.12.7						|| return
	cp -r Documentation/* /usr/share/doc/linux-4.12.7			|| return


	install -v -m755 -d /etc/modprobe.d							|| return
	# Configuring Linux Module Load Order
	echo "
# Begin /etc/modprobe.d/usb.conf
install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true
# End /etc/modprobe.d/usb.conf
" > /etc/modprobe.d/usb.conf									|| return

}

teardown(){
	cd $base_dir
	rm -rfv $pkg_name
}

# Internal process

if [ $status -eq 0 ]; then
	setup >> $log_file 2>&1
	status=$?
fi

if [ $status -eq 0 ]; then
	build >> $log_file 2>&1
	status=$?
fi

if [ $status -eq 0 ]; then
	teardown >> $log_file 2>&1
	status=$?
fi

if [ $status -eq 0 ]; then
	printf "\033[32m[ { ✓ }SUCCESS :: Now lets build the grub] \033[0m\n"
else
	printf "\033[31m[ { ✗ }ERROR ] \033[0m\n"
fi

exit $status