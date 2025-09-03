# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

from libc.string cimport strlen

from .gcry_err cimport gcry_error_t
from .gcry_err cimport gcry_strerror
from .gcry_err cimport gcry_strsource

from typing import Union
from cython import cast, p_uchar, p_char

from ..errors import GcrSexpFormatError


cdef void on_err_raise(gcry_error_t err_code, char * str_src):

    if not err_code:
        return

    description = cast(bytes, gcry_strerror(err_code)).decode(str,'utf-8')
    err_src = cast(bytes, gcry_strsource(err_code)).decode(str,'utf-8')
    cauz = str_src[ : strlen(cast(p_char, str_src))].decode('utf-8')

    raise GcrSexpFormatError(f"libgcrypt error no: #{err_code}",  f"'{description}' raised from {err_src}.", f"Caused by {cauz}", err_code)

def hex_unified(_in_d: Union[str, bytes]) -> str:
    if isinstance(_in_d, bytes):
        return _in_d.hex()
    else:
        return _in_d


def binary_unified(_in_d: Union[str, bytes]) -> bytes:
    if isinstance(_in_d, bytes):
        return _in_d
    else:
        return bytes.fromhex(_in_d)


def s_exp_hex(s_value :Union[str, bytes]=None) -> str:

    return f"#{hex_unified(s_value)}#"

