#!/bin/bash

pkg_source="glibc-2.26.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir															|| return
	tar -xf $pkg_source														|| return
	cd $pkg_name															|| return

}

build(){

	patch -Np1 -i ../glibc-2.26-fhs-1.patch									|| return

	# First create a compatibility symlink to avoid
	# references to /tools in our final glibc:
	ln -sfv /tools/lib/gcc /usr/lib											|| return


	# Determine the GCC include directory and create a
	# symlink for LSB compliance. Additionally, for x86_64,
	#create a compatibility symlink required for the dynamic
	# loader to function correctly:
	case $(uname -m) in
	    i?86)    GCC_INCDIR=/usr/lib/gcc/$(uname -m)-pc-linux-gnu/7.2.0/include
	            ln -sfv ld-linux.so.2 /lib/ld-lsb.so.3
	    ;;
	    x86_64) GCC_INCDIR=/usr/lib/gcc/x86_64-pc-linux-gnu/7.2.0/include
	            ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64
	            ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
	    ;;
	esac

	# Remove a file that may be left over from a previous build attempt:
	rm -f /usr/include/limits.h												|| continue

	mkdir -v build															|| return
	cd build																|| return

	CC="gcc -isystem $GCC_INCDIR -isystem /usr/include" \
	../configure --prefix=/usr                          \
	             --disable-werror                       \
	             --enable-kernel=3.2                    \
	             --enable-stack-protector=strong        \
	             libc_cv_slibdir=/lib
	unset GCC_INCDIR


	make																	|| return

	touch /etc/ld.so.conf													|| return

	# Fix the generated Makefile to skip an uneeded sanity check that
	# fails in the LFS partial environment:
	sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile		|| return

	make install															|| return

	# Install the configuration file and runtime directory for nscd :
	cp -v ../nscd/nscd.conf /etc/nscd.conf									|| return
	mkdir -pv /var/cache/nscd												|| return


	# The following instructions will install the minimum set of
	# locales necessary for the optimal coverage of tests:
	mkdir -pv /usr/lib/locale												|| return
	localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8									|| return
	localedef -i de_DE -f ISO-8859-1 de_DE									|| return
	localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro						|| return
	localedef -i de_DE -f UTF-8 de_DE.UTF-8									|| return
	localedef -i en_GB -f UTF-8 en_GB.UTF-8									|| return
	localedef -i en_HK -f ISO-8859-1 en_HK									|| return
	localedef -i en_PH -f ISO-8859-1 en_PH									|| return
	localedef -i en_US -f ISO-8859-1 en_US									|| return
	localedef -i en_US -f UTF-8 en_US.UTF-8									|| return
	localedef -i es_MX -f ISO-8859-1 es_MX									|| return
	localedef -i fa_IR -f UTF-8 fa_IR										|| return
	localedef -i fr_FR -f ISO-8859-1 fr_FR									|| return
	localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro						|| return
	localedef -i fr_FR -f UTF-8 fr_FR.UTF-8									|| return
	localedef -i it_IT -f ISO-8859-1 it_IT									|| return
	localedef -i it_IT -f UTF-8 it_IT.UTF-8									|| return
	localedef -i ja_JP -f EUC-JP ja_JP										|| return
	localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R								|| return
	localedef -i ru_RU -f UTF-8 ru_RU.UTF-8									|| return
	localedef -i tr_TR -f UTF-8 tr_TR.UTF-8									|| return
	localedef -i zh_CN -f GB18030 zh_CN.GB18030								|| return

	# In addition, install the locale for your own country,
	# language and character set.
	make localedata/install-locales											|| return

	echo "
# Begin /etc/nsswitch.conf
passwd: files
group: files
shadow: files
hosts: files dns
networks: files
protocols: files
services: files
ethers: files
rpc: files
# End /etc/nsswitch.conf
" > /etc/nsswitch.conf														|| return


	# Install and set up the time zone data with the following:
	tar -xf ../../tzdata2017b.tar.gz										|| return
	ZONEINFO=/usr/share/zoneinfo
	mkdir -pv $ZONEINFO/{posix,right}										|| return
	for tz in etcetera southamerica northamerica europe africa antarctica  \
	          asia australasia backward pacificnew systemv; do
	    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
	    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
	    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
	done
	cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO						|| return
	zic -d $ZONEINFO -p America/New_York
	unset ZONEINFO

	cp -v /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime			|| return

	# Configuring the Dynamic Loader
	echo "
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

" > /etc/ld.so.conf															|| return

	echo "
# Add an include directory
include /etc/ld.so.conf.d/*.conf

" >> /etc/ld.so.conf														|| return

	mkdir -pv /etc/ld.so.conf.d												|| return


	# Testing
	# echo 'int main(){}' > dummy.c
	# cc dummy.c -v -Wl,--verbose &> dummy.log
	# readelf -l a.out | grep ': /lib'

	# printf "If the output was:\n"
	# printf "[Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]"
	# printf "\n Then well none. Else, you messed up bru!\n"
	
	# grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
	
	# output :
	# /usr/lib/../lib/crt1.o succeeded
	# /usr/lib/../lib/crti.o succeeded
	# /usr/lib/../lib/crtn.o succeeded

	# grep -B1 '^ /usr/include' dummy.log
	# output:
	# include <...> search starts here:
 	# /usr/include

	# grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
	# output:
	# attempt to open /lib/libc.so.6 succeeded

	# grep found dummy.log
	# found ld-linux-x86-64.so.2 at /lib/ld-linux-x86-64.so.2

	# rm -v dummy.c a.out dummy.log
}

teardown(){
	cd $base_dir
	rm -rfv $pkg_name

	# Adjusting the toolchain
	mv -v /tools/bin/{ld,ld-old}											|| return
	mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}					|| return
	mv -v /tools/bin/{ld-new,ld}											|| return
	ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld				|| return


	gcc -dumpspecs | sed -e 's@/tools@@g'                   \
	    -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
	    -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
	    `dirname $(gcc --print-libgcc-file-name)`/specs						|| return
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
