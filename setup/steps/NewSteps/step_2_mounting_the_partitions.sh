#!/bin/bash

echo $LFS

mkdir -pv $LFS							|| exit
mount -v -t ext4 /dev/sdb1 $LFS			|| exit

mkdir -pv $LFS/boot						|| exit
mount -v -t ext4 /dev/sdb3 $LFS/boot	|| exit

/sbin/swapon -v /dev/sdb4
