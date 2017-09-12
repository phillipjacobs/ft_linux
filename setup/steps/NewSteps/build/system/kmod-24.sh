#!/bin/bash

pkg_source="kmod-24.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir													|| return
	tar -xf $pkg_source												|| return
	cd $pkg_name													|| return
}

build(){
	./configure --prefix=/usr	\
		--bindir=/bin			\
		--sysconfdir=/etc		\
		--with-rootlibdir=/lib	\
		--with-xz				\
		--with-zlib													|| return
	make															|| return
	make install													|| return

	for target in depmod insmod lsmod modinfo modprobe rmmod; do
		ln -sfv ../bin/kmod /sbin/$target							|| return
	done

	ln -sfv kmod /bin/lsmod											|| return
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
