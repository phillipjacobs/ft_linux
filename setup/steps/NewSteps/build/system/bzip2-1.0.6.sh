#!/bin/bash

pkg_source="bzip2-1.0.6.tar.gz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir											|| return
	tar -xf $pkg_source										|| return
	cd $pkg_name											|| return
	patch -Np1 -i ../bzip2-1.0.6-install_docs-1.patch		|| return
}

build(){
	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile		|| return
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile	|| return
	make -f Makefile-libbz2_so								|| return
	make clean												|| return
	make													|| return
	make PREFIX=/usr install								|| return
	cp -v bzip2-shared /bin/bzip2							|| return
	cp -av libbz2.so* /lib									|| return
	ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so		|| return
	rm -v /usr/bin/{bunzip2,bzcat,bzip2}					|| return
	ln -sv bzip2 /bin/bunzip2								|| return
	ln -sv bzip2 /bin/bzcat									|| return
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
