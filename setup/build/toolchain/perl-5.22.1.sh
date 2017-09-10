#!/bin/bash

pkg_source="perl-5.22.1.tar.bz2"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir									|| return
	tar -xf $pkg_source								|| return
	cd $pkg_name									|| return
}

build(){
	sh Configure -des -Dprefix=/tools -Dlibs=-lm	|| return
	make											|| return
	cp -v perl cpan/podlators/pod2man /tools/bin	|| return
	mkdir -pv /tools/lib/perl5/5.22.1				|| return
	cp -Rv lib/* /tools/lib/perl5/5.22.1			|| return
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
