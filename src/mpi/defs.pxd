cdef extern from "gcrypt.h":

    ctypedef struct gcry_mpi:
        pass
    ctypedef gcry_mpi* gcry_mpi_t
