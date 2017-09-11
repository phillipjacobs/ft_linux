#!/bin/bash

pkg_source="systemd-234-lfs.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir													|| return
	tar -xf $pkg_source												|| return
	cd $pkg_name													|| return
	sed -i "s:blkid/::" $(grep -rl "blkid/blkid.h")					|| return
	patch -Np1 -i ../systemd-229-compat-1.patch						|| return
}

build(){
	autoreconf -fi													|| return
	echo 'KILL=/bin/kill
MOUNT_PATH=/bin/mount
UMOUNT_PATH=/bin/umount
HAVE_BLKID=1
BLKID_LIBS="-lblkid"
BLKID_CFLAGS="-I/tools/include/blkid"
HAVE_LIBMOUNT=1
MOUNT_LIBS="-lmount"
MOUNT_CFLAGS="-I/tools/include/libmount"
cc_cv_CFLAGS__flto=no
XSLTPROC="/usr/bin/xsltproc"' > config.cache						|| return
	./configure --prefix=/usr				\
		--sysconfdir=/etc					\
		--localstatedir=/var				\
		--config-cache						\
		--with-rootprefix=					\
		--with-rootlibdir=/lib				\
		--enable-split-usr					\
		--disable-firstboot					\
		--disable-ldconfig					\
		--disable-sysusers					\
		--without-python					\
		--docdir=/usr/share/doc/systemd-229							|| return
	make LIBRARY_PATH=/tools/lib									|| return
	make LD_LIBRARY_PATH=/tools/lib install							|| return
	mv -v /usr/lib/libnss_{myhostname,mymachines,resolve}.so.2 /lib	|| return
	rm -rfv /usr/lib/rpm											|| return
	for tool in runlevel reboot shutdown poweroff halt telinit; do
		ln -sfv ../bin/systemctl /sbin/${tool}						|| return
	done
	ln -sfv ../lib/systemd/systemd /sbin/init						|| return
	systemd-machine-id-setup										|| return
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
