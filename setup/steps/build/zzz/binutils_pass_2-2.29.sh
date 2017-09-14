#!/bin/bash

pkg_source="binutils-2.29.tar.bz2"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir						|| return
	tar -xf $pkg_source					|| return
	cd $pkg_name						|| return
	mkdir -v build						|| return
	cd build							|| return
}

build(){
	CC=$LFS_TGT-gcc                \
	AR=$LFS_TGT-ar                 \
	RANLIB=$LFS_TGT-ranlib         \
	../configure                   \
	    --prefix=/tools            \
	    --disable-nls              \
	    --disable-werror           \
	    --with-lib-path=/tools/lib \
		--with-sysroot					|| return
	make								|| return
	make install						|| return
	make -C ld clean					|| return
	make -C ld LIB_PATH=/usr/lib:/lib	|| return
	cp -v ld/ld-new /tools/bin			|| return
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
