#!/bin/bash

pkg_source="gcc-5.3.0.tar.bz2"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir											|| return
	tar -xf $pkg_source										|| return
	cd $pkg_name											|| return
	mkdir -v build											|| return
	cd       build											|| return
}

build(){
	SED=sed							\
		../configure --prefix=/usr	\
		--enable-languages=c,c++	\
		--disable-multilib			\
		--disable-bootstrap			\
		--with-system-zlib									|| return
	make													|| return
	make install											|| return
	ln -sv ../usr/bin/cpp /lib								|| return
	ln -sv gcc /usr/bin/cc									|| return
	install -v -dm755 /usr/lib/bfd-plugins					|| return
	ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/5.3.0/liblto_plugin.so \
		/usr/lib/bfd-plugins/								|| return
	mkdir -pv /usr/share/gdb/auto-load/usr/lib				|| return
	mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib	|| return
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
