from .gcry_err cimport gcry_error_t, gcry_buffer_t, gpg_error_t
from .gcry_comm cimport gcry_ctx_t, gcry_sexp_t, gcry_mpi_t, gcry_mpi_point_t


cdef extern from "gcrypt.h":

    # ctypedef struct gcry_mpi_point:
    #     pass
    # ctypedef gcry_mpi_point * gcry_mpi_point_t

    #
    # /* Create a new point object.  NBITS is usually 0.  */
    #
    gcry_mpi_point_t gcry_mpi_point_new (unsigned int nbits)

    #
    #/* Release the object POINT.  POINT may be NULL. */
    #
    void gcry_mpi_point_release (gcry_mpi_point_t point)

    #
    #/* Store the projective coordinates X, Y, and Z into POINT.  */
    #
    gcry_mpi_point_t gcry_mpi_point_set (gcry_mpi_point_t point,
                                        gcry_mpi_t x, gcry_mpi_t y, gcry_mpi_t z)

    #
    # /* Get a named point from an elliptic curve context.  */
    #
    gcry_mpi_point_t gcry_mpi_ec_get_point (const char *name,
                                            gcry_ctx_t ctx, int copy)

    #
    # /* Decode and store VALUE into RESULT.  */
    #
    gpg_error_t gcry_mpi_ec_decode_point (gcry_mpi_point_t result,
                                        gcry_mpi_t value, gcry_ctx_t ctx)

    #
    # /* Store the affine coordinates of POINT into X and Y.  */
    #
    int gcry_mpi_ec_get_affine (gcry_mpi_t x, gcry_mpi_t y, gcry_mpi_point_t point,
                                gcry_ctx_t ctx)

    #
    # /* W = 2 * U.  */
    #
    void gcry_mpi_ec_dup (gcry_mpi_point_t w, gcry_mpi_point_t u, gcry_ctx_t ctx)

    #
    # /* W = U + V.  */
    #
    void gcry_mpi_ec_add (gcry_mpi_point_t w,
                        gcry_mpi_point_t u, gcry_mpi_point_t v, gcry_ctx_t ctx)

    #
    # /* W = U - V.  */
    #
    void gcry_mpi_ec_sub (gcry_mpi_point_t w,
                        gcry_mpi_point_t u, gcry_mpi_point_t v, gcry_ctx_t ctx)

    # 
    # /* W = N * U.  */
    #
    void gcry_mpi_ec_mul (gcry_mpi_point_t w, gcry_mpi_t n, gcry_mpi_point_t u,
                        gcry_ctx_t ctx)

    #
    # /* Return true if POINT is on the curve described by CTX.  */
    #
    int gcry_mpi_ec_curve_point (gcry_mpi_point_t w, gcry_ctx_t ctx)
