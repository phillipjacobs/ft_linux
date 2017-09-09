#!/bin/bash

pkg_source="gcc-7.2.0.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir													|| return
	tar -xf $pkg_source												|| return
	cd $pkg_name													|| return
	mkdir -v build													|| return
	cd build														|| return
}

build(){
	../libstdc++-v3/configure			\
		--host=$LFS_TGT					\
		--prefix=/tools					\
		--disable-multilib				\
		--disable-nls					\
		--disable-libstdcxx-threads		\
		--disable-libstdcxx-pch			\
		--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/5.3.0	|| return
	make															|| return
	make install													|| return
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
