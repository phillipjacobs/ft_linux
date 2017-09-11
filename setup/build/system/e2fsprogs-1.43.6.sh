#!/bin/bash

pkg_source="e2fsprogs-1.43.6.tar.gz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir																|| return
	tar -xf $pkg_source															|| return
	cd $pkg_name																|| return
	mkdir -v build																|| return
	cd build																	|| return
}

build(){
	LIBS=-L/tools/lib							\
		CFLAGS=-I/tools/include					\
		PKG_CONFIG_PATH=/tools/lib/pkgconfig	\
		../configure --prefix=/usr				\
		--bindir=/bin							\
		--with-root-prefix=""					\
		--enable-elf-shlibs						\
		--disable-libblkid						\
		--disable-libuuid						\
		--disable-uuidd							\
		--disable-fsck															|| return
	make																		|| return
	ln -sfv /tools/lib/lib{blk,uu}id.so.1 lib									|| return
	make install																|| return
	make install-libs															|| return
	chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a					|| return
	gunzip -v /usr/share/info/libext2fs.info.gz									|| return
	install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info	|| return
	makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo					|| return
	install -v -m644 doc/com_err.info /usr/share/info							|| return
	install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info	|| return
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
