#!/bin/bash

pkg_source="eudev-3.2.2.tar.gz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir														|| return
	tar -xf $pkg_source													|| return
	cd $pkg_name														|| return

	# First, fix a test script:
	sed -r -i 's|/usr(/bin/test)|\1|' test/udev-test.pl					|| return
}

build(){
	# Next, remove an unneeded line that causes a build failure:
	sed -i '/keyboard_lookup_key/d' src/udev/udev-builtin-keyboard.c	|| return


	# Next, add a workaround to prevent the /tools directory from
	# being hard coded into Eudev binary files library locations:
	echo "
HAVE_BLKID=1
BLKID_LIBS=\"-lblkid\"
BLKID_CFLAGS=\"-I/tools/include\"
" > config.cache														|| return
	./configure --prefix=/usr           \
		--bindir=/sbin          \
		--sbindir=/sbin         \
		--libdir=/usr/lib       \
		--sysconfdir=/etc       \
		--libexecdir=/lib       \
		--with-rootprefix=      \
		--with-rootlibdir=/lib  \
		--enable-manpages       \
		--disable-static        \
		--config-cache													|| return


	LIBRARY_PATH=/tools/lib make										|| return

	mkdir -pv /lib/udev/rules.d											|| return
	mkdir -pv /etc/udev/rules.d											|| return

	make LD_LIBRARY_PATH=/tools/lib install								|| return

	# Install some custom rules and support files useful in an LFS environment:
	tar -xvf ../udev-lfs-20140408.tar.bz2								|| return
	make -f udev-lfs-20140408/Makefile.lfs install						|| return

	LD_LIBRARY_PATH=/tools/lib udevadm hwdb --update					|| return


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