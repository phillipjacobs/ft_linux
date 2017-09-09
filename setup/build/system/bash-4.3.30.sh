#!/bin/bash

pkg_source="bash-4.3.30.tar.gz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir										|| return
	tar -xf $pkg_source									|| return
	cd $pkg_name										|| return
	patch -Np1 -i ../bash-4.3.30-upstream_fixes-3.patch	|| return
}

build(){
	./configure --prefix=/usr				\
		--docdir=/usr/share/doc/bash-4.3.30	\
		--without-bash-malloc				\
		--with-installed-readline						|| return
	make												|| return
	make install										|| return
	mv -vf /usr/bin/bash /bin							|| return
	exec /bin/bash --login +h							|| return
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
