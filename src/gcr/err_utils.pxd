
from .gcry_err cimport gcry_error_t


cdef void on_err_raise (gcry_error_t, char *)


