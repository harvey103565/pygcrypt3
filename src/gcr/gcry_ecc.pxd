from .gcry_err cimport gcry_error_t, gcry_buffer_t, gpg_error_t
from .gcry_comm cimport _DEFAULT_ENCODING_, gcry_ctx_t, gcry_sexp_t, gcry_mpi_t, gcry_mpi_point_t


cdef extern from "gcrypt.h":

    ctypedef struct gcry_context:
        pass
    ctypedef gcry_context * gcry_ctx_t

    #
    # /* Allocate a new context for elliptic curve operations based on the
    #   parameters given by KEYPARAM or using CURVENAME.  */
    gpg_error_t gcry_mpi_ec_new (gcry_ctx_t *r_ctx, gcry_sexp_t keyparam, const char *curvename)

    # 
    # /* Release the context object CTX.  */
    # 
    void gcry_ctx_release (gcry_ctx_t ctx)
