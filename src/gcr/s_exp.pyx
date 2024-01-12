# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3


##  cython imports

from libc.stdlib cimport malloc, free

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


from .gcry_err cimport gcry_error_t
from .gcry_mpi cimport gcry_mpi_t
from .err_utils cimport on_err_raise

from .mpi cimport MultiPrecisionInteger

##  Python imports
from typing import Iterator, NoReturn, Self


import cython
from ..errors import GcrSexpError, GcrSexpFormatError, GcrSexpOutOfBoundaryError


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

    _DEFAULT_ENCODING_ = 'utf-8'

    cdef gcry_sexp_t _s_exp
    cdef cython.bint _c_obj_holder

    def __cinit__(self: Self, exp_str: str = None) -> NoReturn:
        """ __cinit__
        Create SymbolicExpression object from string syntax.
        """
        cdef size_t       offset = 0
        cdef gcry_error_t e_code = 0
        self._s_exp = NULL

        if exp_str:
            s_exp_bin_s: bytes = exp_str.encode(SymbolicExpression._DEFAULT_ENCODING_)

            e_code = gcry_sexp_sscan(&self._s_exp, &offset, cython.cast(cython.p_char, s_exp_bin_s), len(s_exp_bin_s))
            on_err_raise(e_code, s_exp_bin_s[ : offset])

            self._c_obj_holder = True


    def __dealloc__(self):
        """ __dealloc__
        Called right before SymbolicExpression object is released. Do cleaning up here.
        """

        if self._c_obj_holder and self._s_exp:
            gcry_sexp_release(self._s_exp)
            self._s_exp = NULL


    def __next__(self: Self) -> Self:
        
        try:
            assert self._iter
            
            self._iter.__next__()
        except StopIteration as stop_sig:
            self._iter = None
            raise stop_sig


    def __repr__(self: Self) -> str:
        """ __repr__() function
        Export the string form of the S-Expression.
        """
        cdef size_t len_cnt = 0
        cdef char * mem_buf = NULL

        try:
            len_cnt = self.size() + 4
            mem_buf = cython.cast(cython.p_char, malloc(len_cnt))

            len_cnt = gcry_sexp_sprint(self._s_exp, gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, mem_buf, len_cnt)
        except Exception as e:
            print(f"Error serializing s-expression object. {e} with context: {e.args}")
        else:
            return cython.cast(bytes, mem_buf[:len_cnt])

        finally:
            if mem_buf:
                free(mem_buf)

    def __str__(self):
        """ __str__() function
        Return S-Expression object in readable format.
        """
        cdef size_t len_cnt = 0
        cdef char * mem_buf = NULL

        try:
            len_cnt = self.size() + 4
            mem_buf = cython.cast(cython.p_char, malloc(len_cnt))

            len_cnt = gcry_sexp_sprint(self._s_exp, gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, mem_buf, len_cnt)
        except Exception as e:
            print(f"Error serializing s-expression object. {e} with context: {e.args}")
        else:
            return cython.cast(bytes, mem_buf[:len_cnt]).decode(SymbolicExpression._DEFAULT_ENCODING_)

        finally:
            if mem_buf:
                free(mem_buf)


    def __len__(self) -> int:
        """
        return the item count number of the S-Expression, in the list perspect of view (including car)
        """
        cdef int lst_cnt = 0

        lst_cnt = gcry_sexp_length(self._s_exp)

        assert lst_cnt > 0
        return lst_cnt


    def __getattr__(self: Self, name: str) -> tuple[bytes]:
        """
            S-Express has a basic form (car . cdr)
            use object.car or object.cdr to get corresponding value
        """
        cdef size_t      data_len = 0
        cdef gcry_sexp_t tar_s_exp = NULL

        c_name_str: bytes = name.encode('utf-8')

        tar_s_exp = gcry_sexp_find_token(self._s_exp, cython.cast(cython.p_char, c_name_str), data_len)
        SymbolicExpression._on_null_expression_raise(tar_s_exp)


    def __hasattr__(self: Self, name: str) -> bool:
        return False


    def __getitem__(self: Self, index: int) -> Self:
        """
            use index to get an expression
        """
        cdef gcry_sexp_t sub_s_exp = NULL

        assert index and isinstance(index, int)

        sub_s_exp = gcry_sexp_nth(self._s_exp, index)
        SymbolicExpression._on_null_expression_raise(sub_s_exp)

        return SymbolicExpression.from_exp_t(sub_s_exp)   


    @property
    def car(self: Self) -> Self:

        cdef gcry_sexp_t sub_s_exp = gcry_sexp_car(self._s_exp)
        SymbolicExpression._on_null_expression_raise(sub_s_exp)
        
        return SymbolicExpression.from_exp_t(sub_s_exp)


    @property
    def cdr(self: Self) -> Self:

        cdef size_t len_cnt = 0
        cdef char[1024] buff

        cdef gcry_sexp_t sub_s_exp = gcry_sexp_cdr(self._s_exp)
        SymbolicExpression._on_null_expression_raise(sub_s_exp)
 
        len_cnt = gcry_sexp_sprint(sub_s_exp, gcry_sexp_format.GCRYSEXP_FMT_DEFAULT, buff, 0)

        return SymbolicExpression.from_exp_t(sub_s_exp)


    @property
    def data(self: Self) -> bytes:
        """ data()
        Get data in bytes from expression
        """

        cdef size_t data_len = 0
        cdef gcry_sexp_t p_s_exp = NULL
        cdef const char * p_data = NULL

        if not self.is_atom():
            # TODO: raise when this is not a plain data
            raise

        p_data = gcry_sexp_nth_data(p_s_exp, 0, &data_len)
        return cython.cast(bytes, p_data[:data_len])


    @property
    def mpi(self: Self) -> bytes:
        """ mpi()
        Get data and convert it to MultiPrecisionInteger class object from expression
        """
        cdef size_t data_len = 0
        cdef gcry_sexp_t p_s_exp = NULL
        cdef const char * p_data = NULL

        if not self.is_atom():
            # TODO: raise when this is not a plain data
            raise

        p_data = gcry_sexp_nth_data(p_s_exp, 0, &data_len)
        return MultiPrecisionInteger(p_data)


    def is_atom(self: Self) -> bool:
        """
        If there is only one data bolb contained in expression, it is an atom.
        """
        return (1 == len(self))


    def size(self: Self) -> int:
        """ size()
        return the S-Expression's memory footprint in bytes
        """
        cdef size_t len_cnt = 0

        len_cnt = gcry_sexp_sprint(self._s_exp, gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, NULL, 0)

        assert len_cnt > 0
        return len_cnt


    @staticmethod
    cdef SymbolicExpression from_exp_t(gcry_sexp_t s_exp, holder: bint = False):
        """Create Sym
        """

        assert s_exp

        cdef SymbolicExpression wrapper_object = SymbolicExpression.__new__(SymbolicExpression)

        wrapper_object._s_exp = s_exp
        wrapper_object._c_obj_holder = holder

        return wrapper_object


    @staticmethod
    cdef void _on_null_expression_raise(gcry_sexp_t s_exp):
        if s_exp == NULL:
            # TODO: raise proper Exception
            raise 

