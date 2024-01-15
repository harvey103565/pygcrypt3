# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3


from ..gcr

cdef class EllipticCurve():
    cdef gcry_ctx_t ec_ctx