# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

from .gcry_err cimport gcry_error_t


cdef void on_err_raise (gcry_error_t, char *)


