# # Cython cimports
from .gcry_ec_point cimport gcry_mpi_point_t, \
    gcry_mpi_point_new, \
    gcry_mpi_point_release, \
    gcry_mpi_point_set, \
    gcry_mpi_ec_get_point, \
    gcry_mpi_ec_decode_point, \
    gcry_mpi_ec_get_affine, \
    gcry_mpi_ec_dup, \
    gcry_mpi_ec_add, \
    gcry_mpi_ec_sub, \
    gcry_mpi_ec_mul, \
    gcry_mpi_ec_curve_point

from .mpi cimport MultiPrecisionInteger
from .elliptic_curve cimport EllipticCurve


# # Python imports
from typing import NoReturn, Self, Generator

import cython

from ..errors import GcrSexpError, GcrSexpFormatError, GcrSexpNilError, GcrSexpOutOfBoundaryError


cdef class ECAffineCoordinatesPoint():

    _X_ = 0
    _Y_ = 1
    
    def __cinit__(self: Self):
        self._coordinates = list()

    def __dealloc__(self: Self):
        pass

    @property
    def x(self: Self) -> MultiPrecisionInteger:
        if self._coordinates[ECAffineCoordinatesPoint._X_] == None:
            self._coordinates[ECAffineCoordinatesPoint._X_] = MultiPrecisionInteger()
        return self._coordinates[ECAffineCoordinatesPoint._X_]

    @x.setter
    def x(self: Self, MultiPrecisionInteger x):
        self._coordinates[ECAffineCoordinatesPoint._X_] = x 

    @property
    def y(self: Self) -> MultiPrecisionInteger:
        if self._coordinates[ECAffineCoordinatesPoint._Y_] == None:
            self._coordinates[ECAffineCoordinatesPoint._Y_] = MultiPrecisionInteger()
        return self._coordinates[ECAffineCoordinatesPoint._Y_]

    @y.setter
    def y(self: Self, MultiPrecisionInteger x):
        self._coordinates[ECAffineCoordinatesPoint._Y_] = x 


cdef class ECMulPrecisIntPoint(ECprojectiveCoordinatesPoint):

    def __cinit__(self: Self, unsigned int nbits):
        self._ec_point = gcry_mpi_point_new(nbits)

    def __dealloc__(self: Self):
        if self._ec_point != NULL:
            gcry_mpi_point_release(self._ec_point)

    def to_affine_coord(self: Self, ecc: EllipticCurve) -> ECAffineCoordinatesPoint:

        cdef gcry_ctx_t ecc_ctx        = NULL
        cdef gcry_mpi_t affine_coord_x = NULL
        cdef gcry_mpi_t affine_coord_y = NULL

        cdef cython.size_t coord_x_len = 0, coord_y_len = 0

        try:
            ecc_ctx = ecc.get_context()
            # point = gcry_mpi_ec_get_point('q', ecc_ctx, 1)
            # if not point:
            #     raise GcryptException(f"Context error: No Q point exist.")

            # affine_coord_x = gcry_mpi_new(GM_T_0003_2_SM2._MPI_N_BITS_)
            # affine_coord_y = gcry_mpi_new(GM_T_0003_2_SM2._MPI_N_BITS_)
        except:
            raise
        
        afc_point = ECAffineCoordinatesPoint()
        cdef cython.bint is_infinity = gcry_mpi_ec_get_affine(&afc_point.x.mpi, &afc_point.y.mpi, self._ec_point, ecc.context)

        return afc_point

    def from_affine_coord(self: Self):
        # invoke gcry_mpi_ec_set_point with the value GCRYMPI_CONST_ONE for z to Convert affine coordinates to projective coordinates
        pass

    @property
    def x(self: Self) -> MultiPrecisionInteger:
        pass

    @property
    def y(self: Self) -> MultiPrecisionInteger:
        pass


    @staticmethod
    cdef ECMulPrecisIntPoint from_mpi_point_t(gcry_mpi_point_t ec_point_ptr):
        cdef ECMulPrecisIntPoint wrapper_object = ECMulPrecisIntPoint.__new__(ECMulPrecisIntPoint)

        assert ec_point_ptr != NULL, "ec_point must not be null"
        wrapper_object._ec_point = ec_point_ptr


