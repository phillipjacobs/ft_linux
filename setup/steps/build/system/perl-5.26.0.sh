#!/bin/bash

pkg_source="perl-5.26.0.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir										|| return
	tar -xf $pkg_source									|| return
	cd $pkg_name										|| return
}

build(){
	echo "127.0.0.1 localhost $(hostname)" > /etc/hosts	|| return
	export BUILD_ZLIB=False								|| return
	export BUILD_BZIP2=0								|| return
	sh Configure -des -Dprefix=/usr		\
		-Dvendorprefix=/usr           \
		-Dman1dir=/usr/share/man/man1 \
		-Dman3dir=/usr/share/man/man3 \
		-Dpager="/usr/bin/less -isR"  \
		-Duseshrplib                  \
		-Dusethreads									|| return
	make												|| return
	make install										|| return
	unset BUILD_ZLIB BUILD_BZIP2						|| return
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
