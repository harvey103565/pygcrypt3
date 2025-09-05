
from .gcry_mpi cimport gcry_mpi_t, gcry_mpi_release
from libc.stdint cimport uintptr_t


##  Python imports
from typing import NoReturn, Self, Generator
import cython


cdef class MultiPrecisionInteger():

    def __cinit__(self: Self):
        """ __cinit__()
        Create SymbolicExpression object from string syntax.
        """
        self._p_mpi_t = NULL


    def __dealloc__(self: Self):
        """ __dealloc__()
        Called right before SymbolicExpression object is released. Do cleaning up here.
        """

        if self._p_mpi_t != NULL:
            gcry_mpi_release(self._p_mpi_t)
            self._p_mpi_t = NULL


    @staticmethod
    cdef MultiPrecisionInteger from_mpi_t(gcry_mpi_t mpi_ptr):
        cdef MultiPrecisionInteger obj = MultiPrecisionInteger.__new__(MultiPrecisionInteger)
        obj._p_mpi_t = mpi_ptr
        return obj
