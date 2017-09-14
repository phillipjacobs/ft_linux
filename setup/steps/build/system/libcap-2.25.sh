#!/bin/bash

pkg_source="libcap-2.25.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir														|| return
	tar -xf $pkg_source													|| return
	cd $pkg_name														|| return
}

build(){
	sed -i '/install.*STALIBNAME/d' libcap/Makefile						|| return
	make																|| return
	make RAISE_SETFCAP=no lib=lib prefix=/usr install					|| return
	chmod -v 755 /usr/lib/libcap.so										|| return
	mv -v /usr/lib/libcap.so.* /lib										|| return
	ln -sfv ../../lib/$(readlink /usr/lib/libcap.so) /usr/lib/libcap.so	|| return
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
