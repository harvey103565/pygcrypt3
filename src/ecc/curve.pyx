# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3



from typing import NoReturn, Self

from cython import cast, p_char

from ..gcr.gcry_comm cimport gpg_error_t
from ..gcr.utils cimport on_err_raise 
from ..gcr.gcry_mpi cimport gcry_mpi_ec_new, gcry_ctx_release
from ..gcr.mpi cimport MultiPrecisionInteger
from ..gcr.s_exp cimport SymbolicExpression
from ..gcr.utils cimport s_exp_hex

from .point cimport ECPoint

cdef class EllipticCurve():

    _P_ = "p"     # p-mpi
    _A_ = "a"     # a-mpi
    _B_ = "b"     # b-mpi
    _G_ = "g"     # g-point
    _N_ = "n"     # n-mpi
    _Q_ = "q"     # q-point
    _D_ = "d"     # d-mpi

    
    def __cinit__(self: Self, name: str=None, **kwds) -> NoReturn:
        cdef gpg_error_t err_no = 0

        if EllipticCurve._D_ in kwds:
            exp_qualifier = "private-key"
            key_qualifier = f"{EllipticCurve._D_} {s_exp_hex(kwds[EllipticCurve._D_])}"
        elif EllipticCurve._Q_ in kwds:
            exp_qualifier = "public-key"
            key_qualifier = f"{EllipticCurve._Q_} {s_exp_hex(kwds[EllipticCurve._Q_])}"
        else:
            raise

        try:
            if name:
                ec_qualifier = f"ecc (curve {name})"
            else:
                ec_qualifier = f"ecc"
                for k in (EllipticCurve._P_, EllipticCurve._A_, EllipticCurve._B_, EllipticCurve._G_, EllipticCurve._N_):
                    ec_qualifier = f"{ec_qualifier} ({k} {s_exp_hex(kwds[k])}) ({key_qualifier})"
        except KeyError as e:
            raise

        s_exp_str = f"({exp_qualifier} ({ec_qualifier}))"
        
        s_exp = SymbolicExpression(s_exp_str.encode('utf-8'))

        err_no = gcry_mpi_ec_new(&self._ec_ctx, s_exp.raw, cast(p_char, name))
        on_err_raise(err_no)


    def __dealloc__(self: Self) -> NoReturn:
        
        if self._ec_ctx:
            gcry_ctx_release(self._ec_ctx)

    @property
    def p(self: Self) -> MultiPrecisionInteger:
        return self._s_exp.p
        
    @property
    def a(self: Self) -> MultiPrecisionInteger:
        return self._s_exp.a
        
    @property
    def b(self: Self) -> MultiPrecisionInteger:
        return self._s_exp.b
        
    @property
    def g(self: Self) -> ECPoint:
        return self._s_exp.g
        
    @property
    def n(self: Self) -> MultiPrecisionInteger:
        return self._s_exp.n
        
    @property
    def q(self: Self) -> ECPoint:
        return self._s_exp.q
        
    @property
    def d(self: Self) -> MultiPrecisionInteger:
        return self._s_exp.d
    
