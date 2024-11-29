# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

# cython imports

from libc.stdlib cimport malloc, free

from .gcry_err cimport gcry_error_t

from .utils cimport on_err_raise

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
                        gcry_sexp_sprint, \
                        gcry_sexp_nth

# Python imports
import cython

from typing import Iterator

from cython import p_char

from ..errors import GcrSexpError, GcrSexpFormatError, GcrSexpOutOfBoundaryError


cdef gcry_error_t err_code = 0
cdef size_t err_offset = 0, lst_cnt = 0, data_len = 0, cnt = 0, cnt_sub = 0, cnt_seek = 0, len_cnt = 0

cdef gcry_sexp_t s_exp_p = NULL, target_sub_exp_p = NULL, tmp_sub_exp_p = NULL, tmp_seek_exp_p = NULL

cdef const char * data_ptr = NULL
cdef const char * sub_data_ptr = NULL

cdef const char * s_exp_str = "(a b (c d) ((e f) g h))"


cdef void print_exp(gcry_sexp_t exp_p, int i, str tag):
    cdef char * mem_buf = NULL

    try:
        if exp_p:
            len_cnt = gcry_sexp_sprint (exp_p, gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, NULL, 0)
            mem_buf = cython.cast(cython.p_char, malloc(len_cnt))
            len_cnt = gcry_sexp_sprint (exp_p, gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, mem_buf, len_cnt)

            print (f"Expression[{i}]  --->     {tag} >>> <STRUCTURE>: \n{cython.cast(bytes, mem_buf).decode('utf-8')}")
        else:
            print (f"")
    finally:
        free(mem_buf)

cdef void release_exp(gcry_sexp_t * exp):
    gcry_sexp_release(exp[0])
    exp[0] = NULL


cdef print_search_token(gcry_sexp_t s_exp_p, const char * data_ptr, size_t data_len, int i, str tag):
    cdef gcry_sexp_t res_exp_p = NULL, iter_exp_p = NULL

    res_exp_p = gcry_sexp_find_token (s_exp_p, data_ptr, data_len)
    cnt = gcry_sexp_length (res_exp_p)

    print (f"Expression[{i}]  --->              {tag} Search Token:<{cython.cast(str, data_ptr)}>:   >>> count {cnt}")
    print_exp(res_exp_p, i, tag)

    for k in range(cnt):
        data_ptr = gcry_sexp_nth_data (res_exp_p, k, &data_len)
        if data_ptr:
            print (f"Expression[{i}]  --->              {tag} Search Token data[{k}] in {cnt}:   >>> {cython.cast(str, data_ptr)}")
        else:
            iter_exp_p = gcry_sexp_nth(res_exp_p, k)
            print_exp(iter_exp_p, i, tag)
            release_exp(&iter_exp_p)

    release_exp(&res_exp_p)


print("--- gcry s_expression demo start.")

err_code = gcry_sexp_sscan (&s_exp_p, &err_offset, s_exp_str, cython.cast(size_t, len(s_exp_str)))
on_err_raise(err_code, cython.cast (p_char, s_exp_str + err_offset))

lst_cnt = gcry_sexp_length (s_exp_p)
for i in range(lst_cnt):

    data_ptr = gcry_sexp_nth_data (s_exp_p, i, &data_len)
    target_sub_exp_p = gcry_sexp_nth (s_exp_p, i)

    if data_ptr == NULL:
        print(f"Expression[{i}]  --->    data[{i}]: <STRUCTURE>: 'NULL'")

        tmp_sub_exp_p = gcry_sexp_car (target_sub_exp_p)
        cnt_sub = gcry_sexp_length (tmp_sub_exp_p)

        print_exp(tmp_sub_exp_p, i, "car")

        for j in range(cnt_sub):
            sub_data_ptr = gcry_sexp_nth_data (tmp_sub_exp_p, j, &data_len)
            print (f"Expression[{i}]  --->      car.data[{j}]{{0-{cnt_sub - 1}}}:   >>> '{cython.cast(str, sub_data_ptr)}'")

            print_search_token(target_sub_exp_p, sub_data_ptr, data_len, i, "Sub")
            print_search_token(s_exp_p, sub_data_ptr, data_len, i, "Full")


            release_exp(&tmp_seek_exp_p)
        release_exp(&tmp_sub_exp_p)

        tmp_sub_exp_p = gcry_sexp_cdr (target_sub_exp_p)
        cnt_sub = gcry_sexp_length (tmp_sub_exp_p)

        print_exp(tmp_sub_exp_p, i, "cdr")

        for j in range(cnt_sub):
            sub_data_ptr = gcry_sexp_nth_data (tmp_sub_exp_p, j, &data_len)
            print (f"Expression[{i}]  --->      cdr.data[{j}]{{0-{cnt_sub - 1}}}:   >>> '{cython.cast(str, sub_data_ptr)}'")

            print_search_token(target_sub_exp_p, sub_data_ptr, data_len, i, "Sub")
            print_search_token(s_exp_p, sub_data_ptr, data_len, i, "Full")

            release_exp(&tmp_seek_exp_p)
        release_exp(&tmp_sub_exp_p)

    else:
        print (f"Expression[{i}]  --->    Data[{i}]:   >>> <STRING>: '{cython.cast(str, data_ptr)}'")

        print_search_token(target_sub_exp_p, data_ptr, data_len, i, "Sub")
        print_search_token(s_exp_p, data_ptr, data_len, i, "Full")

release_exp(&s_exp_p)

print("--- gcry s_expression demo done.")


""" result: 
--- gcry s_expression demo start.
Expression[0]  --->    Data[0]:   >>> <STRING>: 'a'
Expression[0]  --->              Sub Search Token:<a>:   >>> count 1
Expression[0]  --->     Sub >>> <STRUCTURE>: 
(a)

Expression[0]  --->              Sub Search Token data[0] in 1:   >>> a
Expression[0]  --->              Full Search Token:<a>:   >>> count 4
Expression[0]  --->     Full >>> <STRUCTURE>: 
(a b 
 (c d)
 (
  (e f)
  g h)
 )

Expression[0]  --->              Full Search Token data[0] in 4:   >>> a
Expression[0]  --->              Full Search Token data[1] in 4:   >>> b
Expression[0]  --->     Full >>> <STRUCTURE>: 
(c d)

Expression[0]  --->     Full >>> <STRUCTURE>: 
(
 (e f)
 g h)

Expression[1]  --->    Data[1]:   >>> <STRING>: 'b'
Expression[1]  --->              Sub Search Token:<b>:   >>> count 1
Expression[1]  --->     Sub >>> <STRUCTURE>: 
(b)

Expression[1]  --->              Sub Search Token data[0] in 1:   >>> b
Expression[1]  --->              Full Search Token:<b>:   >>> count 0

Expression[2]  --->    data[2]: <STRUCTURE>: 'NULL'
Expression[2]  --->     car >>> <STRUCTURE>: 
(c)

Expression[2]  --->      car.data[0]{0-0}:   >>> 'c'
Expression[2]  --->              Sub Search Token:<c>:   >>> count 2
Expression[2]  --->     Sub >>> <STRUCTURE>: 
(c d)

Expression[2]  --->              Sub Search Token data[0] in 2:   >>> c
Expression[2]  --->              Sub Search Token data[1] in 2:   >>> d
Expression[2]  --->              Full Search Token:<c>:   >>> count 2
Expression[2]  --->     Full >>> <STRUCTURE>: 
(c d)

Expression[2]  --->              Full Search Token data[0] in 2:   >>> c
Expression[2]  --->              Full Search Token data[1] in 2:   >>> d
Expression[2]  --->     cdr >>> <STRUCTURE>: 
(d)

Expression[2]  --->      cdr.data[0]{0-0}:   >>> 'd'
Expression[2]  --->              Sub Search Token:<d>:   >>> count 0

Expression[2]  --->              Full Search Token:<d>:   >>> count 0

Expression[3]  --->    data[3]: <STRUCTURE>: 'NULL'
Expression[3]  --->     car >>> <STRUCTURE>: 
(e f)

Expression[3]  --->      car.data[0]{0-1}:   >>> 'e'
Expression[3]  --->              Sub Search Token:<e>:   >>> count 2
Expression[3]  --->     Sub >>> <STRUCTURE>: 
(e f)

Expression[3]  --->              Sub Search Token data[0] in 2:   >>> e
Expression[3]  --->              Sub Search Token data[1] in 2:   >>> f
Expression[3]  --->              Full Search Token:<e>:   >>> count 2
Expression[3]  --->     Full >>> <STRUCTURE>: 
(e f)

Expression[3]  --->              Full Search Token data[0] in 2:   >>> e
Expression[3]  --->              Full Search Token data[1] in 2:   >>> f
Expression[3]  --->      car.data[1]{0-1}:   >>> 'f'
Expression[3]  --->              Sub Search Token:<f>:   >>> count 0

Expression[3]  --->              Full Search Token:<f>:   >>> count 0

Expression[3]  --->     cdr >>> <STRUCTURE>: 
(g)

Expression[3]  --->      cdr.data[0]{0-0}:   >>> 'g'
Expression[3]  --->              Sub Search Token:<g>:   >>> count 0

Expression[3]  --->              Full Search Token:<g>:   >>> count 0

--- gcry s_expression demo done.
"""