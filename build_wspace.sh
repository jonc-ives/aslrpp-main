
#!/bin/bash

WORKSPACE=$HOME/aslrpp
MISSING_DEP=0

if [ -d $WORKSPACE ]
then
	echo "[WARNING] Workspace Exists: must overwrite workspace directory $WORKSPACE"
	while true; do
    	read -p " Directory $WORKSPACE overwrite okay (y/n)? " yn
    	case $yn in
        	[Yy]* ) sudo -S rm -r $WORKSPACE; break;;
        	[Nn]* ) exit;;
        	* );;
    	esac
	done
fi; mkdir $WORKSPACE
cp -a . $WORKSPACE

for DEP in make texinfo gawk bison perl sed python3 gdb autoconf gettext
do
	if [ $(dpkg-query -W -f='${Status}' $DEP 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		"[ERROR] Dependency Missing: missing glibc dependency $DEP"
		MISSING_DEP=1
	fi
done

if [ $MISSING_DEP -gt 0 ]
then
	exit 1
fi

if [ -d $WORKSPACE/source ]
then
	echo "[WARNING] Workspace Exists: overwriting workspace directory $WORKSPACE/source"
	rm -r $WORKSPACE/source
fi; mkdir $WORKSPACE/source

cd $WORKSPACE/source
echo "[STATUS] Downloading Codebase: downloading glibc codebase"
git clone --quiet https://sourceware.org/git/glibc.git

echo "[STATUS] Downloading Codebase: downloading binutils codebase"
curl https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.gz --output binutils-2.40.tar.gz
tar -xf binutils-2.40.tar.gz
rm binutils-2.40.tar.gz
mv binutils-2.40 binutils

mkdir $WORKSPACE/make
mkdir $WORKSPACE/make/glibc $WORKSPACE/make/binutils

cd $WORKSPACE/make/glibc
echo "[STATUS] Building GLIBC: building GLIBC objects at $WORKSPACE/make/glibc"
$WORKSPACE/source/glibc/configure --prefix=$WORKSPACE/make/glibc
make -s -j

cd $WORKSPACE/make/binutils
echo "[STATUS] Building Binutils: building binutils objects at $WORKSPACE/make/binutils"
CC=gcc $WORKSPACE/source/binutils/configure
make -s -j

mkdir $WORKSPACE/target
cp $WORKSPACE/make/glibc/elf/ld-linux-x86-64.so.2 $WORKSPACE/target
cp $WORKSPACE/make/binutils/ld/ld-new $WORKSPACE/target/ld

echo "[STATUS] Success"

