#!/bin/bash

pkg_source="automake-1.15.1.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir														|| return
	tar -xf $pkg_source													|| return
	cd $pkg_name														|| return
}

build(){
	sed -i 's:/\\\${:/\\\$\\{:' bin/automake.in							|| return
	./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.15.1	|| return
	make																|| return
	sed -i "s:./configure:LEXLIB=/usr/lib/libfl.a &:" t/lex-{clean,depend}-cxx.sh	|| return
	make install														|| return
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
