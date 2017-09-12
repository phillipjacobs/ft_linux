#!/bin/bash

pkg_source="gcc-7.2.0.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir											|| return
	tar -xf $pkg_source										|| return
	cd $pkg_name											|| return

	case $(uname -m) in
	  x86_64)
	    sed -e '/m64=/s/lib64/lib/' \
	        -i.orig gcc/config/i386/t-linux64
	  ;;
	esac

	rm -f /usr/lib/gcc										|| continue

	mkdir -v build											|| return
	cd       build											|| return
}

build(){


	SED=sed								\
	../configure --prefix=/usr			\
		--enable-languages=c,c++		\
		--disable-multilib       		\
		--disable-bootstrap				\
		--with-system-zlib									|| return
	make													|| return


	make install											|| return
	# Create a symlink required by the FHS for "historical" reasons
	ln -sv ../usr/bin/cpp /lib								|| continue

	# Many packages use the name cc to call the C compiler.
	# To satisfy those packages, create a symlink:
	# ln -sv gcc /usr/bin/cc
	ln -sv gcc /usr/bin/cc									|| continue

	# Add a compatibility symlink to enable building programs
	# with Link Time Optimization (LTO):
	install -v -dm755 /usr/lib/bfd-plugins					|| return
	ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/7.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/								|| continue

    # Finally, move a misplaced file:
	mkdir -pv /usr/share/gdb/auto-load/usr/lib				|| continue
	mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib || return
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
