import cython

from cython.cimports cimport p_uchar

from commons cimport gcry_error_t

from commons cimport gcry_strerror
from commons cimport gcry_strsource


from ..py_gcr_errors import GcrSexpFormatError


cdef void on_err_raise (err_code: gcry_error_t, str_src: p_uchar = NULL):

    if not err_code:
        return

    description = cython.cast(bytes, gcry_strerror(err_code)).decode('utf-8')
    err_src = cython.cast(bytes, gcry_strsource(err_code)).decode('utf-8')
    str_src = cython.cast(bytes, str_src).decode('utf-8')

    raise GcrSexpFormatError(f"libgcrypt error no: #{err_code}",  f"'{description}' raised from {err_src}.", f"Caused by {str_src}", err_code)
