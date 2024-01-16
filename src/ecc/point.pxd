# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3


from ..gcr.gcry_comm cimport gpg_error_t, gcry_error_t
from ..gcr.gcry_mpi cimport gcry_mpi_t


from typing import Self, NoReturn

cdef class ECPoint:
    def __cinit__(self: Self, name: str=None, **kwds) -> NoReturn:
        pass

    def __dealloc__(self: Self) -> NoReturn:
        pass

    