#!/bin/bash

pkg_source="mpfr-3.1.5.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir										|| return
	tar -xf $pkg_source									|| return
	cd $pkg_name										|| return
	patch -Np1 -i ../mpfr-3.1.3-upstream_fixes-2.patch	|| return
}

build(){
	./configure --prefix=/usr	\
		--disable-static		\
		--enable-thread-safe	\
		--docdir=/usr/share/doc/mpfr-3.1.3				|| return
	make												|| return
	make html											|| return
	make install										|| return
	make install-html									|| return
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
