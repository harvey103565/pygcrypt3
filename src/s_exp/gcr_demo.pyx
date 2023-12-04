# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

# cython imports

from ..gcr cimport on_err_raise


# Python imports
from typing import Iterator, NoReturn, Self

import cython
from cython import p_uchar, p_void, p_char
from libc.stdlib cimport malloc, free

from ..pygcr_errors import GcrSexpError, GcrSexpFormatError, GcrSexpOutOfBoundaryError


def test_gcr():
    pass

