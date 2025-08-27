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

    def affine_coords(self: Self) -> tuple:
        cdef gcry_error_t err_code = 0

        cdef gcry_mpi_point_t point = NULL

        cdef unsigned char *q_x_bin_s = NULL
        cdef unsigned char *q_y_bin_s = NULL

        cdef int infinity = 0

        cdef gcry_mpi_t affine_coord_x = NULL
        cdef gcry_mpi_t affine_coord_y = NULL

        cdef size_t coord_x_len = 0, coord_y_len = 0

        try:
            point = gcry_mpi_ec_get_point('q', ecc_ctx, 1)
            if not point:
                raise GcryptException(f"Context error: No Q point exist.")

            affine_coord_x = gcry_mpi_new(_MPI_N_BITS_)
            affine_coord_y = gcry_mpi_new(_MPI_N_BITS_)

            infinity = gcry_mpi_ec_get_affine(affine_coord_x, affine_coord_y, point, ecc_ctx)
            if infinity:
                raise GcryptException(f"Invalid Q-Point: <ECC::ZERO>")

            q_x_bin_s = cython.cast(cython.p_uchar, malloc(_MPI_N_BITS_))
            q_y_bin_s = cython.cast(cython.p_uchar, malloc(_MPI_N_BITS_))

            err_code = gcry_mpi_print(gcry_mpi_format.GCRYMPI_FMT_USG, q_x_bin_s, _MPI_N_BITS_, &coord_x_len, affine_coord_x)
            check_err_no_for_exception(err_code)

            err_code = gcry_mpi_print(gcry_mpi_format.GCRYMPI_FMT_USG, q_y_bin_s, _MPI_N_BITS_, &coord_y_len, affine_coord_y)
            check_err_no_for_exception(err_code)

            point_hex = cython.cast(bytes, q_x_bin_s[ : coord_x_len]) + cython.cast(bytes, q_y_bin_s[ : coord_y_len])

            print(f"A - public key: {point_hex.hex().upper()}")

            return point_hex

        finally:
            if affine_coord_x:
                gcry_mpi_release(affine_coord_y)

            if affine_coord_x:
                gcry_mpi_release(affine_coord_x)

            if point:
                gcry_mpi_point_release(point)

            if q_y_bin_s:
                free(q_y_bin_s)

            if q_x_bin_s:
                free(q_x_bin_s)

        return self._s_exp.q
