#!/bin/bash

set +x
WORKSPACE=~/aslrpp
cd $WORKSPACE/make/binutils
#../../source/binutils/configure
make -j
set -x