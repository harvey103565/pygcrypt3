# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

from .gcry_s_exp cimport gcry_sexp_t, \
    gcry_sexp_format, \
    gcry_sexp_sscan, \
    gcry_sexp_length, \
    gcry_sexp_nth_data, \
    gcry_sexp_nth, \
    gcry_sexp_car, \
    gcry_sexp_cdr, \
    gcry_sexp_find_token, \
    gcry_sexp_release, \
    gcry_sexp_sprint

import cython

cdef class SymbolicExpression():
    cdef gcry_sexp_t _s_exp
    cdef cython.bint _c_obj_holder

    @staticmethod
    cdef SymbolicExpression from_exp_t(gcry_sexp_t s_exp, cython.bint holder=?, const char * atom_data=?, int data_len=?)

    @staticmethod
    cdef void _on_null_expression_raise(gcry_sexp_t s_exp)
