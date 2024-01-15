# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3


from ..gcr.gcry_comm cimport gcry_ctx_t

cdef class EllipticCurve():
    cdef gcry_ctx_t _ec_ctx
