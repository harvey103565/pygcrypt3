
from .gcry_comm cimport _DEFAULT_ENCODING_

from .s_exp cimport SymbolicExpression

from typing import Union

import cython

from ..errors import GcrEllipticCurveError


_MPI_N_BITS_    = 32 * 8 / 4

_SIGNATURE_R_   = "r"
_SIGNATURE_S_   = "s"

_CIPHER_C1_     = "a"
_CIPHER_C2_     = "b"
_CIPHER_C3_     = "c"

_PLAIN_TXT_     = "value"


cdef class EccSM2p256v1():

    ecc_sm2p256v1 = {
        'p'  : 'FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF', 
        'n'  : 'FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFF7203DF6B21C6052B53BBF40939D54123', 
        'a'  : 'FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFC', 
        'b'  : '28E9FA9E9D9F5E344D5A9E4BCF6509A7F39789F515AB8F92DDBCBD414D940E93', 
        'Gx' : '32C4AE2C1F1981195F9904466A39C9948FE30BBFF2660BE1715A4589334C74C7', 
        'Gy' : 'BC3736A2F4F6779C59BDCEE36B692153D0A9877CC62A474002DF32E52139F0A0'
    }

    def __init__(self: Self, public_key: Union[str, bytes] = None, private_key: Union[str, bytes] = None):

        assert public_key != None or private_key != None, "At least one key, either public or private key, is REQUIRED."

        if public_key != None:
            if isinstance(public_key , str):
                public_key_data = public_key.encode(_DEFAULT_ENCODING_)
            else:
                public_key_data = public_key

            self._public_key_s_exp = SymbolicExpression(public_key_data)

        if private_key != None:
            if isinstance(public_key , str):
                private_key_data = public_key.encode(_DEFAULT_ENCODING_)
            else:
                private_key_data = public_key

            self._private_key_s_exp = SymbolicExpression(private_key_data)

        

    