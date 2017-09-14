#!/bin/bash

pkg_source="iproute2-4.12.0.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir										|| return
	tar -xf $pkg_source									|| return
	cd $pkg_name										|| return
}

build(){
	sed -i /ARPD/d Makefile								|| return
	sed -i 's/arpd.8//' man/man8/Makefile				|| return
	rm -v doc/arpd.sgml									|| return
	make												|| return
	make DOCDIR=/usr/share/doc/iproute2-4.12.0 install	|| return
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
