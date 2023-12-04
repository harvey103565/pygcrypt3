from cython import p_uchar

from .commons cimport gcry_error_t


cpdef void on_err_raise (err_code: gcry_error_t, str_src: p_uchar)