


from typing import NoReturn, Self

from ..gcr.s_exp cimport SymbolicExpression


cdef class EllipticCurve():
    
    def __cinit__(self: Self, params: dict=None, name: str=None) -> NoReturn:
        if params is None and name is None:
            raise

        if name:
            pass # TODO:
            return
        
        # TODO: initialize object using cutomization prarams
        return

    def __dealloc__(self: Self) -> NoReturn:
        pass
