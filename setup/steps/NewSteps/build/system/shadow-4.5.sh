#!/bin/bash

pkg_source="shadow-4.5.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir										|| return
	tar -xf $pkg_source									|| return
	cd $pkg_name										|| return
}

build(){
	sed -i 's/groups$(EXEEXT) //' src/Makefile.in							|| return
	find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
	find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
	find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
	sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
		-e 's@/var/spool/mail@/var/mail@' etc/login.defs					|| return

	# Shadow with Cracklib support
	sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' etc/login.defs	|| continue

	# Make a minor change to make the default useradd
	# consistent with the LFS groups file
	sed -i 's/1000/999/' etc/useradd										|| return
	

	./configure --sysconfdir=/etc --with-group-name-max-length=32			|| return
	
	make																	|| return
	make install															|| return
	
	mv -v /usr/bin/passwd /bin												|| return
	
	# To enable shadowed passwords, run the following command:
	pwconv																	|| return
	
	# To enable shadowed group passwords, run
	grpconv																	|| return
	
	sed -i 's/yes/no/' /etc/default/useradd									|| return
	
	#  Setting the root password
	passwd root
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
