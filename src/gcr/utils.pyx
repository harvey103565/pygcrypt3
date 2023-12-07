# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

import cython

from cython import p_uchar, p_char

from .commons cimport gcry_error_t

from .commons cimport gcry_strerror
from .commons cimport gcry_strsource

from libc.string cimport strlen

from src.pygcr_errors import GcrSexpFormatError


cdef void on_err_raise (err_code: gcry_error_t, str_src: p_uchar):

    if not err_code:
        return

    description = cython.cast(bytes, gcry_strerror(err_code)).decode(str,'utf-8')
    err_src = cython.cast(bytes, gcry_strsource(err_code)).decode(str,'utf-8')
    cauz = str_src[:strlen(cython.cast(p_char, str_src))]
    str_cauz = cauz.decode('utf-8')

    raise GcrSexpFormatError(f"libgcrypt error no: #{err_code}",  f"'{description}' raised from {err_src}.", f"Caused by {str_cauz}", err_code)
