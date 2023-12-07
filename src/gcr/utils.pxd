from cython import p_uchar

from .commons cimport gcry_error_t


cdef void on_err_raise (gcry_error_t, unsigned char *)
