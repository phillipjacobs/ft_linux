#!/bin/bash

pkg_source="gcc-5.3.0.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir					|| return
	tar -xf $pkg_source				|| return
	cd $pkg_name					|| return
	cat gcc/limitx.h gcc/glimits.h gcc/limity.h	\
		> `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h	|| return
	for file in $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
	do
		cp -uv $file{,.orig}							|| return
		sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g'	\
			-e 's@/usr@/tools@g' $file.orig > $file		|| return
		echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file		|| return
		touch $file.orig								|| return
	done

	tar -xf ../mpfr-3.1.3.tar.xz						|| return
	mv -v mpfr-3.1.3 mpfr								|| return
	tar -xf ../gmp-6.1.0.tar.xz							|| return
	mv -v gmp-6.1.0 gmp									|| return
	tar -xf ../mpc-1.0.3.tar.gz							|| return
	mv -v mpc-1.0.3 mpc									|| return

	mkdir -v build										|| return
	cd build											|| return
}

build(){
	CC=$LFS_TGT-gcc										\
		CXX=$LFS_TGT-g++								\
		AR=$LFS_TGT-ar									\
		RANLIB=$LFS_TGT-ranlib							\
		../configure									\
		--prefix=/tools									\
		--with-local-prefix=/tools						\
		--with-native-system-header-dir=/tools/include	\
		--enable-languages=c,c++						\
		--disable-libstdcxx-pch							\
		--disable-multilib								\
		--disable-bootstrap								\
		--disable-libgomp								|| return
	make												|| return
	make install										|| return
	ln -sv gcc /tools/bin/cc							|| return
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
