
from .gcry_mpi cimport gcry_mpi_t, gcry_mpi_release

from .gcry_ecc cimport gcry_ctx_t
from .gcry_s_exp cimport gcry_sexp_t

from libc.stdint cimport uintptr_t


##  Python imports
from typing import NoReturn, Self, Generator

from typing import NoReturn, Self, Generator

from ..errors import GcrSexpError, GcrSexpFormatError, GcrSexpNilError, GcrSexpOutOfBoundaryError


cdef class MultiPrecisionInteger():

    def __cinit__(self: Self):
        """ __cinit__()
        Create SymbolicExpression object from string syntax.
        """
        self._mpi_t = NULL


    def __dealloc__(self: Self):
        """ __dealloc__()
        Called right before SymbolicExpression object is released. Do cleaning up here.
        """
        if self._mpi_t != NULL:
            gcry_mpi_release(self._mpi_t)
            self._mpi_t = NULL

    cdef gcry_mpi_t mpi(MultiPrecisionInteger self):
        pass

    @staticmethod
    cdef MultiPrecisionInteger from_mpi_t(gcry_mpi_t mpi_ptr):
        cdef MultiPrecisionInteger obj = MultiPrecisionInteger.__new__(MultiPrecisionInteger)
        obj._mpi_t = mpi_ptr
        return obj
