from setuptools import Extension, setup
from Cython.Build import cythonize


"""

Libraries have been installed in:
   /usr/local/lib

If you ever happen to want to link against installed libraries
in a given directory, LIBDIR, you must either use libtool, and
specify the full pathname of the library, or use the `-LLIBDIR'
flag during linking and do at least one of the following:
   - add LIBDIR to the `LD_LIBRARY_PATH' environment variable
     during execution
   - add LIBDIR to the `LD_RUN_PATH' environment variable
     during linking
   - use the `-Wl,-rpath -Wl,LIBDIR' linker flag
   - have your system administrator add LIBDIR to `/etc/ld.so.conf'

See any operating system documentation about shared libraries for
more information, such as the ld(1) and ld.so(8) manual pages.

"""


gcr_sources =  [
    "./src/gcr/s_exp.pyx",
    "./src/gcr/mpi.pyx",
]

c_include_dirs = ["./c_libs/include"]
c_libraries = ["gcrypt"]
c_library_dirs =["./c_libs/lib"]

ext = Extension("pygcrypt", 
    gcr_sources, 
    include_dirs=c_include_dirs, 
    libraries=c_libraries, 
    library_dirs=c_library_dirs,
    extra_link_args=[
        "-Wl,-rpath,$ORIGIN/../../c_libs/lib",      # 关键：$ORIGIN表示二进制文件所在目录
        "-Wl,--disable-new-dtags",                  # 关键：禁用新DTAGS，设置RPATH 而非 RUNPATH，前者将具有遗传特性，
        "-L/workspaces/webdak/webapps/c_libs/lib"   # 编译时库路径
    ])

setup(
    ext_modules=cythonize([ext])
)