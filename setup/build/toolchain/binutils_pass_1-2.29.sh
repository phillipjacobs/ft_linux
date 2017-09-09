#!/bin/bash

pkg_source="binutils-2.29.tar.bz2"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

printf "\nBase Dir = "$base_dir

status=0

setup(){
	cd $base_dir											|| return
	tar -xf $pkg_source										|| return
	cd $pkg_name											|| return
	mkdir -v build											|| return
	cd build												|| return
}

build(){
	../configure --prefix=/tools	\
		--with-sysroot=$LFS			\
		--with-lib-path=/tools/lib	\
		--target=$LFS_TGT			\
		--disable-nls				\
		--disable-werror									|| return
	make													|| return
	case $(uname -m) in
		x86_64)
			mkdir -v /tools/lib && ln -sv lib /tools/lib64	|| return
			;;
	esac
	make install											|| return
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
