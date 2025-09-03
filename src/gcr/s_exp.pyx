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
    gcry_sexp_sprint, \
    gcry_sexp_nth_mpi

from .gcry_err cimport gcry_error_t
from .utils cimport on_err_raise

from .gcry_mpi cimport gcry_mpi_t, gcry_mpi_release
from .mpi cimport MultiPrecisionInteger

##  Python imports
from typing import NoReturn, Self, Generator

import cython

from ..errors import GcrSexpError, GcrSexpFormatError, GcrSexpNilError, GcrSexpOutOfBoundaryError
from cpython.bytes cimport PyBytes_FromStringAndSize

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


    def __cinit__(self: Self, s_exp_bin_str: bytes = None) -> NoReturn:
        """ __cinit__()
        Create SymbolicExpression object from string syntax.
        """
        cdef size_t       offset = 0
        cdef gcry_error_t e_code = 0
        cdef gcry_sexp_t _s_exp = NULL

        if s_exp_bin_str:
            e_code = gcry_sexp_sscan(&self._s_exp, &offset, cython.cast(cython.p_char, s_exp_bin_str), len(s_exp_bin_str))
            on_err_raise(e_code, s_exp_bin_str[ : offset])

            if self._s_exp == NULL:
                raise GcrSexpFormatError(f"S-Expression from '{s_exp_bin_str.decode(SymbolicExpression._DEFAULT_ENCODING_)}' is not allowed.")

            self._atom_data = s_exp_bin_str
            self._c_obj_holder = True


    def __dealloc__(self: Self):
        """ __dealloc__()
        Called right before SymbolicExpression object is released. Do cleaning up here.
        """

        if self._c_obj_holder and self._s_exp:
            gcry_sexp_release(self._s_exp)
            self._s_exp = NULL

    def iterator(self: Self):
        cdef size_t cnt = gcry_sexp_length(self._s_exp)
        for i in range(cnt):
            exp_p = gcry_sexp_nth(self._s_exp, i)
            yield SymbolicExpression.from_exp_t(exp_p, True)

    def _iter(self: Self) -> Generator:
        """ _iter() magic method Generator protocol
        """
        return self.iterator()

    # def __next__(self: Self) -> NoReturn:
    #     """ __next__() magic method Generator protocol
    #     """
    #     try:
    #         assert self._iter
    #         self._iter.__next__()
    #     except StopIteration as stop_sig:
    #         self._iter = None
    #         raise stop_sig

    def __str__(self: Self):
        """ __str__() magic method for built in function: str()

        Convert symbolic expression to string in advanced(human friendly) form
        """
        return self.stringify(gcry_sexp_format.GCRYSEXP_FMT_ADVANCED)


    def __repr__(self: Self):
        """ __repr__() magic method for built in function: repr()

        Convert symbolic expression to string in canonical(strict) form
        """
        return self.stringify(gcry_sexp_format.GCRYSEXP_FMT_CANON)


    def __len__(self: Self) -> int:
        """ __len__() magic method for built in function: len() 
        return the item count number of the S-Expression, in the list perspect of view (including car)
        """
        return gcry_sexp_length(self._s_exp) if self._s_exp else 0


    def __getattr__(self: Self, name: str) -> Self:
        """ __getattr__() magic method for '.property' accessing
            S-Express has a basic form (car . cdr)
            use object.car or object.cdr to get corresponding value
        """
        cdef size_t      data_len = 0
        cdef gcry_sexp_t tar_s_exp = NULL

        c_name_str: bytes = name.encode(SymbolicExpression._DEFAULT_ENCODING_)

        tar_s_exp = gcry_sexp_find_token(self._s_exp, cython.cast(cython.p_char, c_name_str), data_len)
        SymbolicExpression._on_null_expression_raise(tar_s_exp)

        tar_s_exp = gcry_sexp_nth(tar_s_exp, 1)
        return SymbolicExpression.from_exp_t(tar_s_exp, True)


    def __getitem__(self: Self, index: int) -> bytes:
        """ __getitem__() magic method for [] operation
        Return atom data in bytes from expression(list)'s indexed position
        NOTE: None if there is an sub-exp at that position
        """
        cdef size_t      data_len = 0
        cdef const char* data_ptr = NULL

        if not index < len(self):
            raise IndexError('Index out of range', [f"index={index}", f"lenght:{len(self)}"])

        data_ptr = gcry_sexp_nth_data (self._s_exp, index, &data_len)

        if data_ptr != NULL and data_len > 0:
            # 创建 Python bytes 对象（自动复制数据）
            return PyBytes_FromStringAndSize(data_ptr, data_len)
        else:
            return None


    def is_atom(self: Self) -> bool:
        """ is_atom()
        If there is only one data bolb contained in expression, it is an atom.
        """
        if self._s_exp != NULL and 0 == len(self):
            return True
        else:
            return False


    cdef stringify(self: Self, int mode):
        """ stringify()
        Serialize expression and return a string
        """
        cdef char * mem_buf = NULL
        cdef size_t size_cnt = 0
        cdef const char * data_ptr = NULL
        cdef gcry_sexp_t _s_exp = self._s_exp

        try:
            if self.is_atom():
                data_ptr = gcry_sexp_nth_data(_s_exp, 0, &size_cnt)
                str_bytes = PyBytes_FromStringAndSize(data_ptr, size_cnt)
            else:
                size_cnt = SymbolicExpression.string_size(_s_exp, mode)
                mem_buf = cython.cast(cython.p_char, malloc(size_cnt))
                size_cnt = gcry_sexp_sprint(_s_exp, mode, mem_buf, size_cnt)
                str_bytes = PyBytes_FromStringAndSize(mem_buf, size_cnt)

        except Exception as e:
            print(f"Error serializing s-expression object. {e} with context: {e.args}")
            raise GcrSexpError("Error serializing s-expression object") from e
        else:
            return str_bytes.decode(SymbolicExpression._DEFAULT_ENCODING_)
        finally:
            if mem_buf:
                free(mem_buf)


    @property
    def car(self: Self) -> bytes:
        """ car() 
        Return data in bytes from expression's car
        NOTE: libgcry always return atom expression when calling gcry_sexp_car()
        """
        if not self._s_exp:
            raise GcrSexpNilError("nil expression(empty list / atom)")

        cdef gcry_sexp_t sub_s_exp = gcry_sexp_car(self._s_exp)
        SymbolicExpression._on_null_expression_raise(sub_s_exp)

        return SymbolicExpression.from_exp_t(sub_s_exp, True)


    @property
    def cdr(self: Self) -> bytes:
        """ cdr()
        Return data in bytes from expression's cdr
        NOTE: libgcry always return atom expression when calling gcry_sexp_cdr()
        """
        if not self._s_exp:
            raise GcrSexpNilError("nil expression(empty list / atom)")

        if len(self) == 1:
            raise GcrSexpOutOfBoundaryError("Out of boundary: no cdr in expression")

        cdef gcry_sexp_t sub_s_exp = gcry_sexp_cdr(self._s_exp)
        SymbolicExpression._on_null_expression_raise(sub_s_exp)
 
        return SymbolicExpression.from_exp_t(sub_s_exp, True)


    @property
    def data(self: Self) -> bytes:
        """ data()
        Return data in bytes from expression
        """
        cdef size_t data_len = 0
        cdef const char * data_ptr = NULL

        if self.is_atom():
            return self._atom_data

        data_ptr = gcry_sexp_nth_data(self._s_exp, 0, &data_len)
        return cython.cast(bytes, data_ptr[:data_len])


    @property
    def mpi(self: Self) -> bytes:
        """ mpi()
        Get data and convert it to MultiPrecisionInteger class object from expression
        """
        cdef size_t data_len = 0
        cdef gcry_mpi_t p_mpi = NULL

        if not self.is_atom():
            # TODO: raise when this is not a plain data
            raise

        try:
            p_mpi = gcry_sexp_nth_mpi(self._s_exp, 0, &data_len)
            if p_mpi == NULL or data_len == 0:
                raise GcrSexpError("Failed to get MPI data from S-Expression")
            return MultiPrecisionInteger(p_mpi)
        except Exception as e:
            if p_mpi:
                # release the mpi object if it was created
                gcry_mpi_release(p_mpi)
            print(f"Error getting MPI data from s-expression object. {e} with context:")


    @staticmethod
    cdef string_size(gcry_sexp_t _s_exp, int mode):
        """ size()
        return the S-Expression's memory footprint in bytes
        """
        cdef size_t len_cnt = gcry_sexp_sprint(_s_exp, mode, NULL, 0)
        assert len_cnt > 0

        return len_cnt



    @staticmethod
    cdef SymbolicExpression from_exp_t(gcry_sexp_t s_exp, cython.bint holder=True):
        """ from_exp_t()
        StaticClass method to create SymbolicExpression object directly from gcry_s_expression
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
            raise GcrSexpNilError("nil expression")

