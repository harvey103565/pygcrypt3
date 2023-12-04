from ..gcry.commons cimport gcry_error_t
from ..mpi.defs cimport gcry_mpi_t
from ..gcry.commons cimport gcry_buffer_t
from ..gpg_error.defs cimport gpg_error_t

from . import gcry_s_exp as gcr

from cython import p_uchar


cdef class SymbolicExpression():

    cdef gcr.gcry_sexp_p    _s_exp_t
    cdef p_uchar            _s_exp_str


#    def __cinit__(self, s_exp_str: bytes, s_exp_t: gcr.gcry_sexp_p = NULL)
#
#    def __dealloc__(self)
#
#    cpdef void __init__(self, *args: list[bytes], **kwargs: dict[bytes, bytes])
#
#    def __iter__(self) -> Iterator
#
#    def __next__(self, *args, **kwargs) -> str | Self
#
#    def __repr__(self) -> str
#
#    def __len__(self) -> int
#
#    def __getattr__(self, name: str) -> tuple[bytes]
#
#    def __setattr__(self, name: str, value: bytes) -> tuple[bytes]
#
#    def __hasattr__(self, name: str) -> bool
#
#    def __getitem__(self, key: str | int = None) -> bytes | Self
#
#    def __setitem__(self) -> tuple[bytes]
#
#    def is_atom(self) -> size_t
#
#    def size(self) -> size_t
#
#    @staticmethod
#    cdef gcr.gcry_sexp_p _copy_inner_exp_by_car (s_exp: gcr.gcry_sexp_p, car: p_uchar = NULL, key_len: size_t = 0)
#
#    @staticmethod
#    cpdef p_uchar _get_cdr (s_exp: gcr.gcry_sexp_p, cdr_len: size_t)
#
#    @staticmethod
#    cpdef Self _get_by_index (self, i: int)
#
#    @staticmethod
#    cpdef Self _get_by_mapping (self, key: str)
