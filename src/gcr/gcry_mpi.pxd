# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

from .gcry_comm cimport gcry_error_t, gcry_buffer_t, gpg_error_t, gcry_ctx_t, gcry_sexp_t



cdef extern from "gcrypt.h":

    ctypedef struct gcry_mpi:
        pass
    ctypedef gcry_mpi* gcry_mpi_t

    # """
    # Allocate a new context for elliptic curve operations. If keyparam is given, it specifies the parameters of the curve (see ecc_keyparam). 
    # If curvename is given in addition to keyparam and the key parameters do not include a named curve reference, 
    # the string curvename is used to fill in missing parameters. 
    # If only curvename is given, the context is initialized for this named curve.
    # 
    # If a parameter specifying a point (e.g. g or q) is not found, the parser looks for a non-encoded point by appending .x, .y, and .z to the parameter name 
    # and looking them all up to create a point. A parameter with the suffix .z is optional and defaults to 1.
    # 
    # On success the function returns 0 and stores the new context object at r_ctx; this object eventually needs to be released (see gcry_ctx_release). 
    # On error the function stores NULL at r_ctx and returns an error code.
    # """
    gpg_error_t gcry_mpi_ec_new (gcry_ctx_t *r_ctx, gcry_sexp_t keyparam, const char *curvename)

    # """
    # Release the context object ctx and all associated resources. A NULL passed as ctx is ignored.
    # """
    void gcry_ctx_release (gcry_ctx_t ctx)

