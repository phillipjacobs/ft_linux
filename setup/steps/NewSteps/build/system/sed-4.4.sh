#!/bin/bash

pkg_source="sed-4.4.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir													|| return
	tar -xf $pkg_source												|| return
	cd $pkg_name													|| return
}

build(){
	# First fix an issue in the LFS environment and remove a failing test:
	sed -i 's/usr/tools/'                 build-aux/help2man
	sed -i 's/testsuite.panic-tests.sh//' Makefile.in

	./configure --prefix=/usr --bindir=/bin							|| return
	make															|| return
	make html														|| return
	make check
	make install													|| return
	install -d -m755           /usr/share/doc/sed-4.4				|| return
	install -m644 doc/sed.html /usr/share/doc/sed-4.4				|| return
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
