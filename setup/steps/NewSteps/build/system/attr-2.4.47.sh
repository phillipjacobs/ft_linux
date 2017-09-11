#!/bin/bash

pkg_source="attr-2.4.47.src.tar.gz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir															|| return
	tar -xf $pkg_source														|| return
	cd $pkg_name															|| return
}

build(){
	sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in			|| return
	sed -i -e "/SUBDIRS/s|man[25]||g" man/Makefile							|| return
	./configure --prefix=/usr --disable-static								|| return
	make																	|| return
	make install install-dev install-lib									|| return
	chmod -v 755 /usr/lib/libattr.so										|| return
	mv -v /usr/lib/libattr.so.* /lib										|| return
	ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so	|| return
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
