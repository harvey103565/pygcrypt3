# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3


from .gcry_mpi cimport gcry_mpi_t, gcry_mpi_release


cdef class MultiPrecisionInteger:

    cdef gcry_mpi_t _mpi_t

    cdef gcry_mpi_t mpi(MultiPrecisionInteger self)

    @staticmethod
    cdef MultiPrecisionInteger from_mpi_t(gcry_mpi_t mpi_ptr)
