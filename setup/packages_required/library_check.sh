#!/bin/bash

C_RED="printf \033[0;31m"
C_GREEN="printf \033[0;32m"
C_STOP="printf \033[0m"


for lib in lib{gmp,mpfr,mpc}.la; do
  echo $lib: $(if find /usr/lib* -name $lib|
               grep -q $lib;then :;else echo not;fi) found
done
unset lib