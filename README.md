# PyGcrypt3 - Python wrapper for gnu cryptograph library `GPG`

Note: This package using `cython` as glue layer.

The motivation of this package is driven by supporting for Chinese GM algorithms in python. Currently both openssl and libgcrypt have well implementation of them, however, they can not be directly used from python.

## Usage:
For now no installation package is available, to use this package, cython code in this package must be build locally. 

## for SM2/SM3 users:
There are also some introducing docs available, in case you guys wants know-how before starting with SM2/SM3.

## Build:

### prerequisite
To build this package, Libgpg-error, Libgcrypt must be installed as well as gcc tool-chain.
To run this pacakge, Libgcrypt .so library must exists, and could be found during package intailization phase.

### for ubuntu 20.04 or lower users
Libgrypt project announced supporting for SM2/SM3 since version v1.9. Currently, this lib is compiled against libgcrypt-1.11.0 and Libgpg-error-1.51. 
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


### step-1: install python
Suppose python-3.13 is used for developing on ubuntu-20.04. You may want to install Ubuntu Personal Package Archives (PPA) in order to install python-3.13

```bash
# # download pub key
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/deadsnakes.gpg --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776
# # import ppa deadsnakes (python) repository
echo "deb [signed-by=/usr/share/keyrings/deadsnakes.gpg] https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/python.list
# # update 
sudo apt update 
# # installation:
EDBAIN_FRONTEND=noninteractive sudo apt install -y --no-install-recommeds python3.13 python3.13-venv
```

### step-2: create the v-environment
Create a clear virutal evironment for build & developing.
```bash
# # Create venv
python -m venv --symlinks --clear --without-pip ./.venv/< OR PATH_TO_YOUR_VENV>
# # Activate it
source ./.venv/bin/activate
# # Download get-pip.py
curl https://bootstrap.pypa.io/get-pip.py -Lo ./get-pip.py
# # Install pip
python ./get-pip.py
# # Install cython & setuptools 
python -m pip install cython setuptools
# # Install other libs needed by your project
# python -m pip install ......<package names>
```
### step-3: clone this project

```bash
cd /PATH/TO/PYGCRYPT3
git clone git@github.com:harvey103565/pygcrypt3.git
```

### step-4: get libgcrypt


```bash
# # Download libgpg-error
curl https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.51.tar.bz2 -LO
# # Download libgcrypt
curl https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.11.0.tar.bz2 -LO
# # Extract
tar xf libgpg-error-1.51.tar.bz2 && tar xf libgcrypt-1.11.0.tar.bz2 
# # build
cd /PATH/TO/PYGCRYPT3/c_libs/libgpg-error-1.51
./configure --prefix=$(dirname $(pwd)) && make && make check && make install && make clean
cd /PATH/TO/PYGCRYPT3/c_libs/libgcrypt-1.11.0
./configure --prefix=$(dirname $(pwd)) && make && make check && make install && make clean
```

NOTE: you may need to build libgpg-error first then build libgcrypt follow after.

After seeing the test results and benmark summary, you have libgcrypt installed. Now you're good to build this package.
Run `c_libs/bin/gpgrt-config --libs 2>/dev/null` and `c_libs/bin/gpgrt-config --cflags 2>/dev/null` to check the compiling options.


### step-5: build

Just run `python ./setup.py`, that's all.

## Manual

### encrypt/decrypt with sm2

todo:

### digest with sm3

todo:
