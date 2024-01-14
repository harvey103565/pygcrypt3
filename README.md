# PyGcrypt3 - Python wrapper for gnu cryptograph library `GPG`

Note: This package using `cython` as glue layer.

The motivation of this package is driven by supporting for Chinese GM algorithms in python. Currently both openssl and libgcrypt have well implementation of them, however, they can not be directly used from python.

## usage:
For now no installation package is available, to use this package, cython code in this package must be build locally.

## for SM2/SM3 users:
There are also some introducing docs available, in case you guys wants know-how before starting with SM2/SM3.

## build:

### prerequisite
To build this package, Libgpg-error, Libgcrypt must be installed as well as gcc tool-chain.
To run this pacakge, Libgcrypt .so library must exists, and could be found during package intailization phase.

### for ubuntu 20.04 or lower users
Libgrypt project announced supporting for SM2/SM3 since version v1.9. Currently, this lib is compiled against libgcrypt-1.10.2. 
But for ubuntu 20.04, there is an older version v1.8 pre-installed. If happen, users of ubuntu 20.04 or lower should download build libgcrypt source code manually.

Source code could be downloaded from [gnupg.org](https://www.gnupg.org/). Note that `Libgpg-error` will be required during building `Libgcrypt`.

As there will be two libgcrypt.so installed after build, you should build this project follow this:

> Libraries have been installed in:
>    /usr/local/lib
> 
> If you ever happen to want to link against installed libraries
> in a given directory, LIBDIR, you must either use libtool, and
> specify the full pathname of the library, or use the `-LLIBDIR'
> flag during linking and do at least one of the following:
>    - add LIBDIR to the `LD_LIBRARY_PATH' environment variable
>      during execution
>    - add LIBDIR to the `LD_RUN_PATH' environment variable
>      during linking
>    - use the `-Wl,-rpath -Wl,LIBDIR' linker flag
>    - have your system administrator add LIBDIR to `/etc/ld.so.conf'
> 
> See any operating system documentation about shared libraries for
> more information, such as the ld(1) and ld.so(8) manual pages.

When everything is ready, decompress source code and run following in source directory

```bash
make && make check && make install && make clean
```