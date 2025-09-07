


from .gcry_comm cimport gcry_ctx_t, gcry_sexp_t, gcry_mpi_t, gcry_mpi_point_t


cdef class ECprojectiveCoordinatesPoint():
    pass


cdef class ECAffineCoordinatesPoint():

    cdef list _coordinates


cdef class ECMulPrecisIntPoint(ECprojectiveCoordinatesPoint):

    cdef gcry_mpi_point_t  _ec_point

    @staticmethod
    cdef ECMulPrecisIntPoint from_mpi_point_t(gcry_mpi_point_t ec_point_ptr)

    cdef gcry_mpi_point_t mpi(ECMulPrecisIntPoint self)
