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


grcy_utils_sources =  [
    "./src/gcr/utils.pyx"
]

s_exp_sources =  [
    # "./src/s_exp/wrapper.pyx", 
    "./src/s_exp/gcr_demo.pyx"
]

c_include_dirs = ["/usr/local/include"]
c_libraries = ["gcrypt"]
c_library_dirs =["./c_libs"]

extension = []

setup(ext_modules=cythonize([
        Extension("src.gcr.utils", 
                  grcy_utils_sources, 
                  include_dirs=c_include_dirs, 
                  libraries=c_libraries, 
                  library_dirs=c_library_dirs),
        Extension("src.s_exp.gcr_demo", 
                  s_exp_sources, 
                  include_dirs=c_include_dirs, 
                  libraries=c_libraries, 
                  library_dirs=c_library_dirs)])
)