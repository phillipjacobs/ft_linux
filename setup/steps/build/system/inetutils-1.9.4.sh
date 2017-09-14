#!/bin/bash

pkg_source="inetutils-1.9.4.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir											|| return
	tar -xf $pkg_source										|| return
	cd $pkg_name											|| return
	patch -Np1 -i ../inetutils-1.9-PATH_PROCNET_DEV.patch	|| return
}

build(){
	./configure --prefix=/usr	\
		--localstatedir=/var	\
		--disable-logger		\
		--disable-whois			\
		--disable-rcp			\
		--disable-rexec			\
		--disable-rlogin		\
		--disable-rsh			\
		--disable-servers									|| return

	make													|| return
	make check
	make install											|| return
	
	mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin	|| return
	mv -v /usr/bin/ifconfig /sbin							|| return
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

exit $status
