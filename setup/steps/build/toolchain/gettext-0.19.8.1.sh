#!/bin/bash

pkg_source="gettext-0.19.8.1.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir											|| return
	tar -xf $pkg_source										|| return
	cd $pkg_name											|| return
}

build(){
	cd gettext-tools										|| return
	EMACS="no" ./configure --prefix=/tools --disable-shared	|| return
	make -C gnulib-lib										|| return
	make -C intl pluralx.c									|| return
	make -C src msgfmt										|| return
	make -C src msgmerge									|| return
	make -C src xgettext									|| return
	cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin			|| return
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
