#!/bin/bash

pkg_source="ncurses-6.0.tar.gz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir					|| return
	tar -xf $pkg_source				|| return
	cd $pkg_name					|| return
}

build(){
	sed -i s/mawk// configure		|| return
	./configure --prefix=/tools	\
		--with-shared			\
		--without-debug			\
		--without-ada			\
		--enable-widec			\
		--enable-overwrite			|| return
	make							|| return
	make install					|| return
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
