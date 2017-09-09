#!/bin/bash

pkg_source="binutils-2.26.tar.bz2"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir										|| return
	tar -xf $pkg_source									|| return
	cd $pkg_name										|| return
	expect -c "spawn ls"								|| return
	patch -Np1 -i ../binutils-2.26-upstream_fix-2.patch	|| return
	mkdir -v build										|| return
	cd       build										|| return
}

build(){
	../configure --prefix=/usr	\
		--enable-shared			\
		--disable-werror								|| return
	make tooldir=/usr									|| return
	make tooldir=/usr install							|| return
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
