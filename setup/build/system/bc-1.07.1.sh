#!/bin/bash

pkg_source="bc-1.07.1.tar.gz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir									|| return
	tar -xf $pkg_source								|| return
	cd $pkg_name									|| return
	patch -Np1 -i ../bc-1.06.95-memory_leak-1.patch	|| return
}

build(){
	./configure --prefix=/usr	\
		--with-readline			\
		--mandir=/usr/share/man	\
		--infodir=/usr/share/info					|| return
	make											|| return
	make install									|| return
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
