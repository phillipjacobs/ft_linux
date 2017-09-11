#!/bin/bash

pkg_source="xz-5.2.3.tar.xz"

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
	sed -e '/mf\.buffer = NULL/a next->coder->mf.size = 0;'	\
		-i src/liblzma/lz/lz_encoder.c										|| return
	./configure --prefix=/usr	\
		--disable-static		\
		--docdir=/usr/share/doc/xz-5.2.2									|| return
	make																	|| return
	make install															|| return
	mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin					|| return
	mv -v /usr/lib/liblzma.so.* /lib										|| return
	ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so	|| return
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
