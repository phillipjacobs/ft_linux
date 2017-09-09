#!/bin/bash

pkg_source="glibc-2.23.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir															|| return
	tar -xf $pkg_source														|| return
	cd $pkg_name															|| return
	patch -Np1 -i ../glibc-2.23-fhs-1.patch									|| return
	mkdir -v build															|| return
	cd build																|| return
}

build(){
	../configure --prefix=/usr	\
		--disable-profile		\
		--enable-kernel=2.6.32	\
		--enable-obsolete-rpc												|| return
	make																	|| return
	touch /etc/ld.so.conf													|| return
	make install															|| return
	cp -v ../nscd/nscd.conf /etc/nscd.conf									|| return
	mkdir -pv /var/cache/nscd												|| return
	install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf	|| return
	install -v -Dm644 ../nscd/nscd.service /lib/systemd/system/nscd.service	|| return
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
	make localedata/install-locales											|| return
	echo "# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns myhostname
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf" >	/etc/nsswitch.conf								|| return
	tar -xf ../../tzdata2016a.tar.gz										|| return
	ZONEINFO=/usr/share/zoneinfo											|| return
	mkdir -pv $ZONEINFO/{posix,right}										|| return
	for tz in etcetera southamerica northamerica europe africa antarctica asia australasia backward pacificnew systemv; do
		zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}	|| return
		zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}	|| return
		zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}	|| return
	done
	cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO						|| return
	zic -d $ZONEINFO -p America/New_York									|| return
	unset ZONEINFO															|| return
	ln -sfv /usr/share/zoneinfo/Europe/Paris /etc/localtime					|| return
	echo "# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
" > /etc/ld.so.conf															|| return

	echo "# Add an include directory
include /etc/ld.so.conf.d/*.conf
" >> /etc/ld.so.conf														|| return
	mkdir -pv /etc/ld.so.conf.d												|| return
}

teardown(){
	cd $base_dir
	rm -rfv $pkg_name
	mv -v /tools/bin/{ld,ld-old}											|| return
	mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}					|| return
	mv -v /tools/bin/{ld-new,ld}											|| return
	ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld				|| return
	gcc -dumpspecs | sed -e 's@/tools@@g'					\
		-e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}'	\
		-e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >		\
		`dirname $(gcc --print-libgcc-file-name)`/specs
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
