#!/bin/bash

pkg_source="procps-ng-3.3.11.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir																|| return
	tar -xf $pkg_source															|| return
	cd $pkg_name																|| return
}

build(){
	./configure --prefix=/usr						\
		--exec-prefix=								\
		--libdir=/usr/lib							\
		--docdir=/usr/share/doc/procps-ng-3.3.11	\
		--disable-static							\
		--disable-kill								\
		--with-systemd															|| return
	make																		|| return
	make install																|| return
	mv -v /usr/lib/libprocps.so.* /lib											|| return
	ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so	|| return
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
