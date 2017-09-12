#!/bin/bash

pkg_source="coreutils-8.27.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir													|| return
	tar -xf $pkg_source												|| return
	cd $pkg_name													|| return
	patch -Np1 -i ../coreutils-8.27-i18n-1.patch					|| return
}

build(){

	sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk
	
	FORCE_UNSAFE_CONFIGURE=1 ./configure	\
		--prefix=/usr						\
		--enable-no-install-program=kill,uptime						|| return
	
	FORCE_UNSAFE_CONFIGURE=1 make									|| return
	
	make NON_ROOT_USERNAME=nobody check-root

	echo "dummy:x:1000:nobody" >> /etc/group

	chown -Rv nobody .

	su nobody -s /bin/bash \
          -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"

   	sed -i '/dummy/d' /etc/group


	make install													|| return


	mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
	mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
	mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
	mv -v /usr/bin/chroot /usr/sbin
	mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
	sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8

	mv -v /usr/bin/{head,sleep,nice,test,[} /bin

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
