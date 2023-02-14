#!/bin/bash

set +x
WORKSPACE=~/aslrpp
cd $WORKSPACE/make/glibc
#../../source/glibc/configure --prefix=$WORKSPACE/make/glibc
make -j
set -x