#!/bin/bash

pkg_source="glibc-2.26.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir							|| return
	tar -xf $pkg_source						|| return
	cd $pkg_name							|| return
	mkdir -v build							|| return
	cd build								|| return
}

build(){
	../configure						   \
		--prefix=/tools                    \
		--host=$LFS_TGT                    \
		--build=$(../scripts/config.guess) \
		--enable-kernel=3.2                \
		--with-headers=/tools/include      \
		libc_cv_forced_unwind=yes          \
		libc_cv_c_cleanup=yes				|| return
	make									|| return
	make install							|| return
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
