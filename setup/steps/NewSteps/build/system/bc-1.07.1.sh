#!/bin/bash

pkg_source="bc-1.07.1.tar.gz"

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

	echo "
#! /bin/bash
sed -e '1   s/^/{\"/' \
    -e     's/$/\",/' \
    -e '2,$ s/^/\"/'  \
    -e   '$ d'       \
    -i libmath.h
sed -e '$ s/$/0}/' \
    -i libmath.h
" > bc/fix-libmath_h

	ln -sv /tools/lib/libncursesw.so.6 /usr/lib/libncursesw.so.6
	ln -sfv libncurses.so.6 /usr/lib/libncurses.so

	sed -i -e '/flex/s/as_fn_error/: ;; # &/' configure

	./configure --prefix=/usr	\
		--with-readline			\
		--mandir=/usr/share/man	\
		--infodir=/usr/share/info					|| return
	make											|| return
	make install									|| return
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
