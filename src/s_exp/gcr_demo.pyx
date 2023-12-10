# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

# cython imports

from ..gcr.utils cimport on_err_raise

# Python imports
from typing import Iterator

import cython
from cython import p_uchar

from . cimport gcry_s_exp as gcr
from ..pygcr_errors import GcrSexpError, GcrSexpFormatError, GcrSexpOutOfBoundaryError


def test_gcr():

    cdef gcr.gcry_error_t err_code = 0
    cdef size_t err_offset = 0,lst_cnt = 0, data_len = 0, cnt = 0, cnt_sub = 0, cnt_seek = 0

    cdef gcr.gcry_sexp_t s_exp_p = NULL, tmp_exp_p = NULL, tmp_sub_exp_p = NULL, tmp_seek_exp_p = NULL
    cdef const char * data_ptr = NULL


    cdef const char * s_exp_str = "(a b (c d) ((e f) g h))"

    err_code = gcr.gcry_sexp_sscan (&s_exp_p, &err_offset, s_exp_str, cython.cast(size_t, len(s_exp_str)))
    on_err_raise(err_code, cython.cast (p_uchar, s_exp_str[err_offset]))

    lst_cnt = gcr.gcry_sexp_length (s_exp_p)
    for i in range(lst_cnt):
        data_ptr = gcr.gcry_sexp_nth_data(s_exp_p, i, &data_len)
        tmp_exp_p = gcr.gcry_sexp_nth (s_exp_p, i)
        if data_ptr == NULL:
            print(f"Expression[{i}]  --=>    data[{i}]: <Structure>")

            tmp_sub_exp_p = gcr.gcry_sexp_car (tmp_exp_p)
            cnt_sub = gcr.gcry_sexp_length (tmp_sub_exp_p)
            for j in range(cnt_sub):
                data_ptr = gcr.gcry_sexp_nth_data(tmp_sub_exp_p, j, &data_len)
                print (f"Expression[{i}]  --=>      car.data[{j}]{{0-{cnt_sub - 1}}}:   ++> {cython.cast(str, data_ptr)}")

                tmp_seek_exp_p = gcr.gcry_sexp_find_token (s_exp_p, data_ptr, data_len)
                cnt_seek = gcr.gcry_sexp_length (tmp_seek_exp_p)
                print (f"Expression[{i}]  --=>      Token:<{cython.cast(str, data_ptr)}>:   ++> count {cnt_seek}")

                for k in range(cnt_seek):
                    data_ptr = gcr.gcry_sexp_nth_data(tmp_seek_exp_p, k, &data_len)
                    print (f"Expression[{i}]  --=>          Token data[{k}] in data{{0-{cnt_seek - 1}}}:   ++> {cython.cast(str, data_ptr)}")

            tmp_sub_exp_p = gcr.gcry_sexp_cdr (tmp_exp_p)
            cnt_sub = gcr.gcry_sexp_length (tmp_sub_exp_p)
            for j in range(cnt_sub):
                data_ptr = gcr.gcry_sexp_nth_data(tmp_sub_exp_p, j, &data_len)
                print (f"Expression[{i}]  --=>      cdr.data[{j}]{{0-{cnt_sub - 1}}}:   ++> {cython.cast(str, data_ptr)}")

                tmp_seek_exp_p = gcr.gcry_sexp_find_token (s_exp_p, data_ptr, data_len)
                cnt_seek = gcr.gcry_sexp_length (tmp_seek_exp_p)
                print (f"Expression[{i}]  --=>      Token:<{cython.cast(str, data_ptr)}>:   ++> count {cnt_seek}")

                for k in range(cnt_seek):
                    data_ptr = gcr.gcry_sexp_nth_data(tmp_seek_exp_p, k, &data_len)
                    print (f"Expression[{i}]  --=>          Token data[{k}] in data{{0-{cnt_seek - 1}}}:   ++> {cython.cast(str, data_ptr)}")


        else:
            print (f"Expression[{i}]  --=>    Data[{i}]:   ++> {cython.cast(str, data_ptr)}")

            tmp_seek_exp_p = gcr.gcry_sexp_find_token (s_exp_p, data_ptr, data_len)
            cnt_seek = gcr.gcry_sexp_length (tmp_seek_exp_p)
            print (f"Expression[{i}]  --=>      Token:<{cython.cast(str, data_ptr)}>:   ++> count {cnt_seek}")

            for k in range(cnt_seek):
                data_ptr = gcr.gcry_sexp_nth_data(tmp_seek_exp_p, k, &data_len)
                if data_ptr != NULL:
                    print (f"Expression[{i}]  --=>          Token data[{k}] in data{{0-{cnt_seek - 1}}}:   ++> {cython.cast(str, data_ptr)}")
                else:
                    print (f"Expression[{i}]  --=>          Token data[{k}]: NULL")


""" result: 
Expression[0]  --=>    Data[0]:   ++> a
Expression[0]  --=>      Token:<a>:   ++> count 4
Expression[0]  --=>          Token data[0] in data{0-3}:   ++> a
Expression[0]  --=>          Token data[1] in data{0-3}:   ++> b
Expression[0]  --=>          Token data[2]: NULL
Expression[0]  --=>          Token data[3]: NULL
## Expression[0]  --=>      car.data[0]{0-0}:   ++> a
Expression[1]  --=>    Data[1]:   ++> b
Expression[1]  --=>      Token:<b>:   ++> count 0
Expression[2]  --=>    data[2]: <Structure>
Expression[2]  --=>      car.data[0]{0-0}:   ++> c
Expression[2]  --=>      Token:<c>:   ++> count 2
Expression[2]  --=>          Token data[0] in data{0-1}:   ++> c
Expression[2]  --=>          Token data[1] in data{0-1}:   ++> d
Expression[2]  --=>      cdr.data[0]{0-0}:   ++> d
Expression[2]  --=>      Token:<d>:   ++> count 0
Expression[3]  --=>    data[3]: <Structure>
Expression[3]  --=>      car.data[0]{0-1}:   ++> e
Expression[3]  --=>      Token:<e>:   ++> count 2
Expression[3]  --=>          Token data[0] in data{0-1}:   ++> e
Expression[3]  --=>          Token data[1] in data{0-1}:   ++> f
Expression[3]  --=>      car.data[1]{0-1}:   ++> f
Expression[3]  --=>      Token:<f>:   ++> count 0
Expression[3]  --=>      cdr.data[0]{0-0}:   ++> g
Expression[3]  --=>      Token:<g>:   ++> count 0
"""