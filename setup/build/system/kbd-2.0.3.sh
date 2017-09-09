#!/bin/bash

pkg_source="kbd-2.0.3.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir																	|| return
	tar -xf $pkg_source																|| return
	cd $pkg_name																	|| return
	patch -Np1 -i ../kbd-2.0.3-backspace-1.patch									|| return
	sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure							|| return
	sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in							|| return
}

build(){
	PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock	|| return
	make																			|| return
	make install																	|| return
	mkdir -v /usr/share/doc/kbd-2.0.3												|| return
	cp -R -v docs/doc/* /usr/share/doc/kbd-2.0.3									|| return
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
