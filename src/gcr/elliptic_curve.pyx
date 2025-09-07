# # Cython cimports
from .gcry_err cimport gcry_error_t
from .gcry_comm cimport _DEFAULT_ENCODING_, gcry_ctx_t, gcry_sexp_t, gcry_mpi_t, gcry_mpi_point_t


from .grcy_ecc cimport  gcry_ctx_t, \
                        gcry_mpi_ec_new, \
                        gcry_ctx_release, \
                        gcry_mpi_ec_get_point

from ..errors cimport GcrEllipticCurveError
from .s_exp cimport SymbolicExpression
from .ecc_sm2p256v1 cimport _SM2_CANON_NAME_ 


# # Python imports
from typing import NoReturn, Self, Generator, Union, Any

import cython

from ..errors import GcrSexpError, GcrSexpFormatError, GcrSexpNilError, GcrSexpOutOfBoundaryError


cdef class EllipticCurve():


    def __cinit__(self: Self, s_exp: SymbolicExpression, ecc_name: str):
        cdef gcry_error_t err_code = gcry_mpi_ec_new(&self._ec_ctx, s_exp.this, ecc_name.encode(_DEFAULT_ENCODING_))
        assert err_code == 0, f"Failed to create ec-curve."

    def __dealloc__(self: Self):
        pass

    def get_context(self: Self):
        return self._ec_ctx

    def get_point(self: Self, pt_name: str):
        try:
            point = gcry_mpi_ec_get_point(pt_name.encode(_DEFAULT_ENCODING_), self._ec_ctx, 1)
            if not point:
                raise GcrEllipticCurveError(f"Context error: No {pt_name} point exist.")
        except:
            raise

    def encrypt(self: Self, data: Union[bytes, str], padding: Any) -> bytes:

        cipher = SymbolicExpression()
        message = SymbolicExpression()

        pass

    def decrypt(self: Self, data: bytes) -> bytes:
        pass

    def sign(self: Self, data: bytes, digester=None) -> bytes:
        pass

    def verify(self: Self, signature: bytes, digester=None) -> bool:
        pass

    cdef gcry_ctx_t get_context(EllipticCurve self):
        pass
