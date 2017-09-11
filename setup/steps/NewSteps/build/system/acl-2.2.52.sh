#!/bin/bash

pkg_source="acl-2.2.52.src.tar.gz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir														|| return
	tar -xf $pkg_source													|| return
	cd $pkg_name														|| return
}

build(){
	sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in		|| return
	sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test				|| return
	sed -i -e "/TABS-1;/a if (x > (TABS-1)) x = (TABS-1);"	\
		libacl/__acl_to_any_text.c										|| return
	./configure --prefix=/usr	\
		--disable-static		\
		--libexecdir=/usr/lib											|| return
	make																|| return
	make install install-dev install-lib								|| return
	chmod -v 755 /usr/lib/libacl.so										|| return
	mv -v /usr/lib/libacl.so.* /lib										|| return
	ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so	|| return
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
