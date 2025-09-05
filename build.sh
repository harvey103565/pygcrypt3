#! /usr/bin/bash

export LIBDIR=/python/lib
# export LIBDIR=/usr/local/lib

export LD_LIBRARY_PATH=${LIBDIR}
export LD_RUN_PATH=${LIBDIR}

source .venv/bin/activate

echo ' ==>(0): Determine library evnironment.'
echo 'library: gcrypt could be found and linked via: '
gpgrt-config --libs 2>/dev/null
gpgrt-config --cflags 2>/dev/null

echo ' ==>(1): compile cypthon.'
rm -rf ./build/ 

echo ' ==>(2): compile cypthon.'
python setup.py build_ext

echo ' ==>(3): mv.'
mv -f build/lib.linux-x86_64-cpython-313/pygcrypt.cpython-313-x86_64-linux-gnu.so src/gcr/pygcrypt.so

# echo ' ==>(3): Clean stale builds.'
# rm -rf ./build/* 2>&1 >/dev/null

# echo ' ==>(4): Clean stale builds.'
# chown harvey:harvey ./pygcr/s_exp.so
