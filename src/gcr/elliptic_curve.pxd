
from .gcry_comm cimport  gcry_ctx_t, gcry_sexp_t, gcry_mpi_t, gcry_mpi_point_t


cdef class EllipticCurve():

    cdef gcry_ctx_t _ec_ctx
    
    cdef gcry_ctx_t get_context(EllipticCurve self)
