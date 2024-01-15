# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

from .gcry_comm cimport gcry_error_t, gcry_buffer_t, gpg_error_t



cdef extern from "gcrypt.h":

    ctypedef struct gcry_mpi:
        pass
    ctypedef gcry_mpi* gcry_mpi_t