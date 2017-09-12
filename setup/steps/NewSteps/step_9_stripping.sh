#!/bin/sh

# user enable to run script :: lfs

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ { ✗ }ERROR  ] LFS variable not present. Check step 1\033[0m\n"
	exit 1
else
	printf "\033[32m[ { ✓ }SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

# The steps in this section are optional, but if the LFS partition is
# rather small, it is beneficial to learn that unnecessary items can
# be removed. The executables and libraries built so far contain about
# 70 MB of unneeded debugging symbols. Remove those symbols with:
strip --strip-debug /tools/lib/*
/usr/bin/strip --strip-unneeded /tools/{,s}bin/*

# To save more, remove the documentation:
rm -rf /tools/{,share}/{info,man,doc}

