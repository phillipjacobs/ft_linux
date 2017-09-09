#!/bin/bash

C_RED="printf \033[0;31m"
C_GREEN="printf \033[0;32m"
C_STOP="printf \033[0m"

# Simple script to list version numbers of critical development tools
export LC_ALL=C
bash --version | head -n1 | cut -d" " -f2-4

MYSH=$(readlink -f /bin/sh)

$C_GREEN
printf "/bin/sh -> $MYSH\n\n"
$C_STOP

echo $MYSH | grep -q bash || echo "ERROR: /bin/sh does not point to bash"
unset MYSH
echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-
bison --version | head -n1
if [ -h /usr/bin/yacc ]; then
  echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
elif [ -x /usr/bin/yacc ]; then
  echo yacc is `/usr/bin/yacc --version | head -n1`
else
  printf "yacc not found" 
fi
bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-
echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
diff --version | head -n1
find --version | head -n1
gawk --version | head -n1
if [ -h /usr/bin/awk ]; then
  echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
elif [ -x /usr/bin/awk ]; then
  echo awk is `/usr/bin/awk --version | head -n1`
else 
  printf "awk not found" 
fi


gcc --version | head -n1
g++ --version | head -n1
ldd --version | head -n1 | cut -d" " -f2-  # glibc version
grep --version | head -n1
gzip --version | head -n1
cat /proc/version
m4 --version | head -n1
make --version | head -n1
patch --version | head -n1
echo Perl `perl -V:version`
sed --version | head -n1
tar --version | head -n1
# makeinfo --version | head -n1
xz --version | head -n1


echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
if [ -x dummy ]
  then
  	$C_GREEN;
  	printf "\ng++ compilation OK\n";
  else
  	printf "\ng++ compilation failed\n";
fi
rm -f dummy.c dummy
$C_STOP