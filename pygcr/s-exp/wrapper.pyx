# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

# cython imports
from cython.cimports import p_uchar, p_void, p_char

from ..gcry.utils cimport on_err_raise

cimport gcry_s_exp as gcr


# Python imports
from typing import Iterator, NoReturn, Self

import cython
from cython.cimports.libc.stdlib import malloc, free

from ..py_gcr_errors import GcrSexpError, GcrSexpFormatError, GcrSexpOutOfBoundaryError


cdef class SymbolicExpression():
    """ class SymbolicExpression

    A python wrapper of gcry_sexp_t type, which is widely used in gpg's cryptography.

    Explaintion from [S-Expression.org](https://www.s-expressions.org/home):

        'S-Expressions' which is also known as 'symbolic expressions' are a type of notation used to represent structured data.
        An S-expression can be defined recursively as one of the following:
            - An atom (described below)             -or-
            - An ordered pair of S-expressions

        1. Atoms
        An atom can represent any valid object other than an ordered pair. 
        Although valid atoms differ by context, they generally comprise numbers and symbols.

        2. Ordered Pairs
        An ordered pair can be represented by its two members separated by a whitespace delimited '.' enclosed by a pair of parenthesis. 
        For example, an ordered pair of atoms x and y can be represented as:
            (x . y)

        3. Lists
        Lists are a special kind of S-expression defined recursively as either:
            - An empty list                                                           -or-
            - An ordered pair where the second member is also a list
            - An empty list can be represented as an empty pair of parenthesis:  ()

        A non-empty list can be represented as a chain of nested pairs. For example, a list containing the atoms x, y and z can be represented as:
            (x . (y . (z . ())))

        A list can also be represented by its members delimited by whitespace and enclosed by a single pair of parenthesis. 
        For example, the same list from the previous example can be represented as:
            (x y z)

        4. Association Lists
        Lists of ordered pairs can be used to associate keys with values. For example the association of keys A, B and C with values 1, 2 and 3 can be represented as follows:
        (
            (A . 1)	
            (B . 2)	
            (C . 3)
        )

    Simplify rules; 'S-Expressions' could be simplified by removing dot('.') inside, by obey the rules:

        - If a dot is to the left side of the left-bracket, such as '(a . (b . c))' form, the dot and these brackets could be omitted. 
            For example: '(a . (b . c))' <=> '(a b . c)'; ** NOTE ** dot between 'b' and 'c' still exists.
        - If a dot is to the left side of nil, such as '(a . (b . nil))' , the dot, the nil value and those brackets wrap it could be omitted.
            For example: (a . (b . nil)) <=> (a b . nil) <=> (a b)

        Here: nil <=> () <=> 'FALSE'; ** NOTE ** nil do not means nothing, so we can't add a 'nil' to any list.
            For example above: (x . (y . (z . ()))) <=>  (x y z); And (x y z)  < != > (x y . z) but (x y . z ())

    As of explainations above, the SymbolicExpression should offer 3 ways of accessing data inside a 'S-Expression':
        - The pair way: Obj.car <=> car: <value> | inner_s_exp; Obj.cdr <=> cdr: <value> | inner_s_exp | 'nil'
        - The list way: Obj[int] <=> inner_s_exp.car: <value> | inner_s_exp | 'nil'
        - The dict way: Obj['car'] <=> cdr: <value> | inner_s_exp | 'nil'
        - Try to get value from 'nil' with any method will always result in an error
    """

    cdef gcr.gcry_sexp_p    _s_exp_t
    cdef p_uchar            _s_exp_str

    def __cinit__(self, s_exp_str: bytes, s_exp_t: gcr.gcry_sexp_p = NULL):
        """ __cinit__

        Called after SymbolicExpression object is created but before __init__() is invoked. Only static variables should be initiated, no other actions here.
            's_exp_str': a s-expression in string format, which will be parsed into gcry_sexp_t inside libgcrypt. This is the common way to create an object.
            's_exp_t': a s-expression object from outside. When this parameter is present, 's_exp_str' will be ingored and should be passed as 'None'

        """

        cdef gcr.gcry_error_t err_code
        cdef size_t err_offset = 0, s_exp_size = 0

        self._s_exp_t = NULL

        if s_exp_t:
            # expression length 
            s_exp_size = gcr.gcry_sexp_canon_len (cython.cast (p_uchar, &self._s_exp_t), 0, &err_offset, &err_code)
            on_err_raise(err_code, cython.cast (p_uchar, s_exp_str[err_offset:]))
            # create a copy of expression
            err_code = gcr.gcry_sexp_new (&self._s_exp_t, s_exp_t, s_exp_size, 1)
            on_err_raise(err_code, cython.cast (p_uchar, s_exp_str[err_offset:]))
        else:
            # create express object from string
            err_code = gcr.gcry_sexp_sscan (&self._s_exp_t, &err_offset, s_exp_str, cython.cast(size_t, len(s_exp_str)))
            on_err_raise(err_code, cython.cast (p_uchar, s_exp_str[err_offset:]))

    def __dealloc__(self):
        """ __dealloc__

        Called right before SymbolicExpression object is released. Do cleaning up here.

        """

        if self._s_exp_t:
            gcr.gcry_sexp_release(self._s_exp_t)
            self._s_exp_t = NULL


    cpdef NoReturn __init__(self, *args: list[bytes], **kwargs: dict[bytes, bytes]):
        """ __init__

        Pythonic init function. Dynamic variables should be initialized here.

        """

    def __iter__(self) -> Iterator:

        cpdef s_exp_generator():

            cdef size_t list_cnt = 0, i = 0
            
            list_cnt = gcr.gcry_sexp_length (self._s_exp_t)

            for i in range(list_cnt):
                yield self[i]
        
        if not self._iter:
            self._iter = s_exp_generator()


    def __next__(self, *args, **kwargs) -> str | Self:
        
        try:
            assert self._iter
            
            self._iter.__next__(*args, **kwargs)
        except StopIteration as stop_sig:
            self._iter = None
            raise stop_sig

    def __repr__(self) -> str:
        """ __repr__() function

        Export the string form of the S-Expression.

        """
        cdef size_t len_cnt = 0
        cdef p_uchar mem_buf = NULL

        try:
            len_cnt = self.size()
            len_cnt = len_cnt + 4
            mem_buf = cython.cast(cython.p_char, malloc(len_cnt))

            len_cnt = gcr.gcry_sexp_sprint (self._s_exp_t, gcr.gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, mem_buf, len_cnt)

            # TODO: logging print(f"S-expression <{len_cnt - 4} bytes> {cython.cast(bytes, mem_buf)}")

        except:
            # TODO: logging
            pass

        else:
            return cython.cast(bytes, mem_buf[:len_cnt])

        finally:

            if mem_buf:
                free(mem_buf)


    def __len__(self) -> int:
        """

            return the item count number of the S-Expression, in the list perspect of view (including car)

        """
        cdef int lst_cnt = 0

        assert self._s_exp_t
        lst_cnt = gcr.gcry_sexp_length (self._s_exp_t)

        assert lst_cnt > 0
        return lst_cnt


    def __getattr__(self, name: str) -> tuple[bytes]:
        """
            S-Express has a basic form (car . cdr)
            use object.car or object.cdr to get corresponding value
        """
        cdef gcr.gcry_sexp_p s_exp = NULL

        try:
            if name == 'car':
                s_exp =  gcr.gcry_sexp_car (self._s_exp_t)  
                pass
            elif name == 'cdr':
                s_exp = gcr.gcry_sexp_cdr (self._s_exp_t)
                pass
            else:
                raise AttributeError("Invalid attribute", f"{type(self)} don not have attribute '{name}'")
        except:
            pass

        else:
            pass

        finally:
            if s_exp:
                gcr.gcry_sexp_release(s_exp)

    def __setattr__(self, name: str, value: bytes) -> tuple[bytes]:
        """
            S-Express has a basic form (car . cdr)
            use object.car = 'some-name' or object.cdr = 'some-value' to set its value
        """
        try:
            if name == 'car':
                pass
            elif name == 'cdr':
                pass
            else:
                raise AttributeError("Invalid attribute", f"{type(self)} don not have attribute '{name}'")
        except:
            pass

        else:
            pass

        finally:
            # if s_exp:
            #     gcr.gcry_sexp_release(s_exp)
            pass


    def __hasattr__(self, name: str) -> bool:
        return False

    def __getitem__(self, key: str | int = None) -> bytes | Self:
        """
            use object['car-name'] to get cdr
        """
        cdef gcr.gcry_sexp_p s_exp = NULL
        cdef p_uchar data_ptr = NULL
        cdef size_t i = 0, data_len = 0

        if isinstance(key, str):
            name = key.encode('utf-8')
            try:
                if name == self.car:
                    return self.cdr
                elif len(self) == 1:
                    return None
                else:
                    s_exp = SymbolicExpression._copy_inner_exp_by_car(self._s_exp_t, cython.cast(p_uchar, name), cython.cast(size_t, len(key)))
                    assert s_exp

                    if len(self) == 2:
                        # TODO: <value>
                        pass
                    else:
                        return SymbolicExpression(s_exp)
            except:
                pass

            else:
                return 

            finally:
                if s_exp:
                    gcr.gcry_sexp_release(s_exp)

        elif isinstance(key, int):
            i = cython.cast(size_t, key)
            data_ptr = gcr.gcry_sexp_nth_data(self._s_exp_t, i, &data_len)
            if not data_ptr:
                raise GcrSexpOutOfBoundaryError(f"List index #{key} out of boundary exception. (@gcry_sexp_nth_data)")

        else:
            raise

    def __setitem__(self) -> tuple[bytes]:
        """
            use object['car-name'] = 'cdr-value' to set cdr value
        """
        pass

    def is_atom(self) -> size_t:
        pass

    def size(self) -> size_t:
        """ size()

            return the S-Expression's memory footprint in bytes

        """
        cdef size_t len_cnt = 0

        assert self._s_exp_t
        len_cnt = gcr.gcry_sexp_sprint (self._s_exp_t, gcr.gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, NULL, 0)

        assert len_cnt > 0
        return len_cnt

    @staticmethod
    cdef gcr.gcry_sexp_p _copy_inner_exp_by_car (s_exp: gcr.gcry_sexp_p, car: p_uchar = NULL, key_len: size_t = 0):

        cdef gcr.gcry_error_t err_code = 0
        cdef gcr.gcry_sexp_t tar_s_exp = NULL
        cdef size_t data_len = 0

        assert s_exp
        assert car

        try:
            tar_s_exp = gcr.gcry_sexp_find_token(s_exp, cython.cast(p_uchar, car), key_len)
            if not tar_s_exp:
                raise GcrSexpError(f"<error: #{err_code}>: token: {car} not found in S-Expression (@gcry_sexp_find_token).")

            # data_v = gcr.gcry_sexp_nth_data(tar_s_exp, list_index, &data_len)
            # if not data_v:
            #     raise GcrSexpError(f"List index #{list_index} out of boundary exception. (@gcry_sexp_nth_data)")

            # return data_v[ : data_len]
            return None

        except GcrSexpError as err:
            raise err

        finally:

            if tar_s_exp:
                gcr.gcry_sexp_release(tar_s_exp)

    @staticmethod
    cpdef p_uchar _get_cdr (s_exp: gcr.gcry_sexp_p, cdr_len: size_t):
        pass


    @staticmethod
    cpdef Self _get_by_index (self, i: int):
        pass


    @staticmethod
    cpdef Self _get_by_mapping (self, key: str):
        pass
