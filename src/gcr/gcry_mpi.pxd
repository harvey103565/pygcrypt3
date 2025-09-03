# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

from .gcry_comm cimport gcry_error_t, gcry_buffer_t, gpg_error_t, gcry_ctx_t, gcry_sexp_t



cdef extern from "gcrypt.h":

    ctypedef struct gcry_mpi:
        pass
    ctypedef gcry_mpi* gcry_mpi_t

    cdef enum gcry_mpi_format:
        GCRYMPI_FMT_NONE= 0,
        GCRYMPI_FMT_STD = 1,
        GCRYMPI_FMT_PGP = 2,
        GCRYMPI_FMT_SSH = 3,
        GCRYMPI_FMT_HEX = 4,
        GCRYMPI_FMT_USG = 5,
        GCRYMPI_FMT_OPAQUE = 8

    ctypedef struct gcry_mpi_point:
        pass 
    ctypedef gcry_mpi_point* gcry_mpi_point_t




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

    # """ 
    # large numbers are called MPIs (multi-precision-integers). 
    # Public key cryptography is based on mathematics with large numbers. These functions are exposed 
    # """
    gcry_mpi_t gcry_mpi_new (unsigned int nbits)

    void gcry_mpi_release (gcry_mpi_t a)

    gcry_error_t gcry_mpi_print (gcry_mpi_format format, unsigned char *buffer, size_t buflen, size_t *nwritten, const gcry_mpi_t a)

    gcry_error_t gcry_mpi_aprint (gcry_mpi_format format, unsigned char **buffer, size_t *nbytes, const gcry_mpi_t a)


    # """ 
    # Points in MPI coordinate system 
    # projective coordinates from a Point on each axis of 3-Dimensionality system are MPI.
    # Currently Only ECC functions implement context. Use gcry_mpi_ec_new to create one.
    # """

    gpg_error_t gcry_mpi_ec_new (gcry_ctx_t *r_ctx, gcry_sexp_t keyparam, const char *curvename)

    void gcry_ctx_release (gcry_ctx_t ctx)

    void gcry_mpi_point_release (gcry_mpi_point_t point)

    gcry_mpi_point_t gcry_mpi_ec_get_point (const char *name, gcry_ctx_t ctx, int copy)

    void gcry_mpi_point_get (gcry_mpi_t x, gcry_mpi_t y, gcry_mpi_t z, gcry_mpi_point_t point)

    int gcry_mpi_ec_get_affine ( gcry_mpi_t x, gcry_mpi_t y, gcry_mpi_point_t point, gcry_ctx_t ctx)


    gpg_error_t gcry_mpi_ec_set_point (const char *name,  gcry_ctx_t ctx)
    
    gpg_error_t gcry_mpi_ec_set_mpi (const char *name, gcry_mpi_t newvalue, gcry_ctx_t ctx)

    gcry_mpi_t gcry_mpi_ec_get_mpi (const char *name, gcry_ctx_t ctx, int copy)

