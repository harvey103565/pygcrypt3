# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

# cython imports

from ..gcr.utils cimport on_err_raise

# Python imports
from typing import Iterator, NoReturn, Self

import cython
from cython import p_uchar, p_void, p_char
from libc.stdlib cimport malloc, free

from . cimport gcry_s_exp as gcr

from ..pygcr_errors import GcrSexpError, GcrSexpFormatError, GcrSexpOutOfBoundaryError


def test_gcr():

    cdef gcr.gcry_error_t err_code = 0
    cdef size_t err_offset = 0, s_exp_size = 0, lst_cnt = 0, data_len, cnt =0

    cdef gcr.gcry_sexp_t s_exp_p = NULL, tmp_exp_p = NULL
    cdef const char * data_ptr = NULL


    cdef const char * s_exp_str = "(a b (c d) e (f g))"

    err_code = gcr.gcry_sexp_sscan (&s_exp_p, &err_offset, s_exp_str, cython.cast(size_t, len(s_exp_str)))
    on_err_raise(err_code, cython.cast (p_uchar, s_exp_str[err_offset]))

    lst_cnt = gcr.gcry_sexp_length (s_exp_p)
    for i in range(lst_cnt):
        data_ptr = gcr.gcry_sexp_nth_data(s_exp_p, i, &data_len)
        if data_ptr == NULL:
            print(f"--=>    Null data[{i}]")
            tmp_exp_p = gcr.gcry_sexp_nth (s_exp_p, i)

            cnt = gcr.gcry_sexp_length (tmp_exp_p)
            for i in range(cnt):
                data_ptr = gcr.gcry_sexp_nth_data(tmp_exp_p, i, &data_len)
                print (f"--=>      Sub data[{i}] in data{{{cnt}}}:   ++> {cython.cast(str, data_ptr)}")

        else:
            print (f"--=>    Data[{i}]   in data{{{lst_cnt}}}:   ++> {cython.cast(str, data_ptr)}")

        tmp_exp_p = gcr.gcry_sexp_nth (s_exp_p, i)
        if tmp_exp_p == NULL:
            print (f"--=>      Expression[{i}]: NULL")
        else:
            cnt = gcr.gcry_sexp_length (tmp_exp_p)
            print (f"--=>      Expression[{i}]: length: {cnt}")
            data_ptr = gcr.gcry_sexp_nth_data(tmp_exp_p, 0, &data_len)
            print (f"--=>      data[0] in Expression[{i}]:   ++> {cython.cast(str, data_ptr)}")


