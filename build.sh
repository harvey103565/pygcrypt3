#! /usr/bin/bash

export LIBDIR=/opt/python/lib/libgpg/lib
# export LIBDIR=/usr/local/lib

export LD_LIBRARY_PATH=${LIBDIR}
export LD_RUN_PATH=${LIBDIR}

source ~/studio/python/bin/activate

echo ' ==>(0): Determine library evnironment.'
echo 'library: gcrypt could be found and linked via: '
c_libs/bin/gpgrt-config --libs 2>/dev/null
c_libs/bin/gpgrt-config --cflags 2>/dev/null

echo ' ==>(1): compile cypthon.'
rm -rf ./build/ 

echo ' ==>(2): compile cypthon.'
python setup.py build_ext --inplace

# echo ' ==>(2): compiling cypthon.'
# mv -f ./pygcr/s_exp.cpython-311-x86_64-linux-gnu.so ./pygcr/s_exp.so

# echo ' ==>(3): Clean stale builds.'
# rm -rf ./build/* 2>&1 >/dev/null

# echo ' ==>(4): Clean stale builds.'
# chown harvey:harvey ./pygcr/s_exp.so
