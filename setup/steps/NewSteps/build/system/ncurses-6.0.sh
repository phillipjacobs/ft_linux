#!/bin/bash

pkg_source="ncurses-6.0.tar.gz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir												|| return
	tar -xf $pkg_source											|| return
	cd $pkg_name												|| return
}

build(){
	sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in					|| return
	./configure --prefix=/usr	\
		--mandir=/usr/share/man	\
		--with-shared			\
		--without-debug			\
		--without-normal		\
		--enable-pc-files		\
		--enable-widec											|| return
	
	make														|| return
	make install												|| return

	mv -v /usr/lib/libncursesw.so.6* /lib						|| return

	# Because the libraries have been moved, one symlink
	# points to a non-existent file. Recreate it
	ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) \
	/usr/lib/libncursesw.so 									|| return

	for lib in ncurses form panel menu ; do
		rm -vf                    /usr/lib/lib${lib}.so			|| return
		echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so			|| return
		ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc	|| return
	done

	# Finally, make sure that old applications that look for
	# -lcurses at build time are still buildable:
	rm -vf                     /usr/lib/libcursesw.so			|| return
	echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so			|| return
	ln -sfv libncurses.so      /usr/lib/libcurses.so			|| return

	# Install ncurses documentation
	mkdir -v /usr/share/doc/ncurses-6.0							|| return
	cp -v -R doc/* /usr/share/doc/ncurses-6.0					|| return
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
