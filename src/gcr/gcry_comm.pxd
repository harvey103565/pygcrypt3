

_DEFAULT_ENCODING_ = 'utf-8'


cdef extern from "gcrypt.h":

    ctypedef struct gcry_sexp:
        pass
    ctypedef gcry_sexp* gcry_sexp_t

    ctypedef struct gcry_context:
        pass 
    ctypedef gcry_context* gcry_ctx_t

    ctypedef struct gcry_mpi:
        pass
    ctypedef gcry_mpi * gcry_mpi_t

    ctypedef struct gcry_mpi_point:
        pass
    ctypedef gcry_mpi_point * gcry_mpi_point_t

    ctypedef void (* p_freefnc) (void* )

    cdef enum gcry_sexp_format:
        GCRYSEXP_FMT_DEFAULT   = 0,
        GCRYSEXP_FMT_CANON     = 1,
        GCRYSEXP_FMT_BASE64    = 2,
        GCRYSEXP_FMT_ADVANCED  = 3
