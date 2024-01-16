# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3


from ..gcr.gcry_mpi cimport gcry_mpi_t


cdef class ECPoint():
    pass