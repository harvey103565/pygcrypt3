
# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

from .gcry_err cimport gcry_error_t, gcry_buffer_t, gpg_error_t



cdef extern from "gcrypt.h":

    ctypedef struct gcry_sexp:
        pass
    ctypedef gcry_sexp* gcry_sexp_t

    ctypedef struct gcry_context:
        pass 
    ctypedef gcry_context* gcry_ctx_t
