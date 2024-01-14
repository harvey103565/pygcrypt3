# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

"""
# distutils: include_dirs = /opt/python/include/site/python3.11/gcrypt
# distutils: sources = /usr/lib/x86_64-linux-gnu/libgcrypt.a
"""

from typing import Union

import cython

from webapps.modules.pygcrypt.errors import GcryptException

from cython.cimports.libc.stdlib import malloc, free
from cython.cimports.libc.string import strlen


from ..gcr.s_exp cimport SymbolicExpression


cdef class Sm2():
    """
    """

    ecc_sm2p256v1 = {
        'p'  : 'FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF', 
        'n'  : 'FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFF7203DF6B21C6052B53BBF40939D54123', 
        'a'  : 'FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFC', 
        'b'  : '28E9FA9E9D9F5E344D5A9E4BCF6509A7F39789F515AB8F92DDBCBD414D940E93', 
        'Gx' : '32C4AE2C1F1981195F9904466A39C9948FE30BBFF2660BE1715A4589334C74C7', 
        'Gy' : 'BC3736A2F4F6779C59BDCEE36B692153D0A9877CC62A474002DF32E52139F0A0'
    }


    _CANON_NAME_    = "sm2p256v1"
    _OID_           = "1.2.156.10197.1.301"

    _MPI_N_BITS_    = 32 * 8 / 4

    _SIGNATURE_R_   = "r"
    _SIGNATURE_S_   = "s"

    _CIPHER_C1_     = "a"
    _CIPHER_C2_     = "b"
    _CIPHER_C3_     = "c"

    _PLAIN_TXT_     = "value"

    cdef SymbolicExpression _pub_key_exp

    # cdef gcr.gcry_sexp_t _a_pub_key_s_exp
    cdef SymbolicExpression _sec_key_exp

    # cdef gcr.gcry_ctx_t _ecc_curve_ctx

    _Qa: bytes
    _e: bytes

    def __cinit__(self, pub_key: bytes=None, prv_key: bytes=None):

        self._pub_key_exp = NULL
        self._sec_key_exp = NULL
        
        self._pub_key_exp = SymbolicExpression(pub_key)
        self._sec_key_exp = SymbolicExpression(prv_key)

        # self._ecc_curve_ctx   = GM_T_0003_2_SM2.create_ecc_context(self._sec_key_exp)


    def __init__(self, *args, **kwds):

        try:
            self._Qa = GM_T_0003_2_SM2.get_q(self._ecc_curve_ctx)
            self._a_pub_key_s_exp  = GM_T_0003_2_SM2.s_exp_key(True, b'\x04' + self._Qa)

            self._e = self.sm3_hash(buffs =(self._Za(),))

        except GcryptException as err:
            raise err
        
    def __dealloc__(self):

        if self._pub_key_exp:
            gcr.gcry_sexp_release(self._pub_key_exp)
            self._pub_key_exp = NULL

        if self._sec_key_exp:
            gcr.gcry_sexp_release(self._sec_key_exp)
            self._sec_key_exp = NULL

        if self._a_pub_key_s_exp:
            gcr.gcry_sexp_release(self._a_pub_key_s_exp)
            self._a_pub_key_s_exp = NULL

        if self._ecc_curve_ctx:
            gcr.gcry_ctx_release(self._ecc_curve_ctx)
            self._ecc_curve_ctx = NULL


    def verify(self, signature :Union[str, bytes]=None, _M :Union[str, bytes]=None, asn1 :bool=False) -> bool:

        cdef gcr.gcry_sexp_t data_s_exp = NULL
        cdef gcr.gcry_sexp_t sig_s_exp = NULL

        try:

            _bM = GM_T_0003_2_SM2.binary_unified(_in_d =_M)
            _Ea = self.sm3_hash(buffs =(self._e, _bM))
            data_s_exp = GM_T_0003_2_SM2.s_exp_data(data =_Ea.hex())

            # print(f"Verifying data: '_e': '{self._e.hex().upper()}' ;  '_M': '{_bM.hex().upper()}';  (@verify())")
            sig_s_exp = GM_T_0003_2_SM2.s_exp_signature(sig =signature)

            err_code = gcr.gcry_pk_verify(sig_s_exp, data_s_exp, self._a_pub_key_s_exp)
            GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

            return True

        except Exception as err:
            print (f"{err.__str__()}")
            return False

        finally:
            if sig_s_exp:
                gcr.gcry_sexp_release(sig_s_exp)

            if data_s_exp:
                gcr.gcry_sexp_release(data_s_exp)



    def sign(self, data :Union[str, bytes]=None) -> tuple[bytes]:
        """
            signature_text = "(sig-val (sm2 (r #..hex32...#) (s #..hex32...#)))"
        """
        cdef gcr.gcry_error_t err_code = 0

        cdef gcr.gcry_sexp_t data_s_exp = NULL
        cdef gcr.gcry_sexp_t sig_s_exp = NULL

#         " ====================== DEBUG SIGN-SELF GENERATED START ======================="
#         cdef gcr.gcry_sexp_t pkey_s_exp = NULL
#         cdef size_t size = 0
#         cdef cython.p_char ch_buf = NULL
#         " ====================== DEBUG SIGN-SELF GENERATED END ========================="

        try:
            data_s_exp = GM_T_0003_2_SM2.s_exp_data(data=data)

            err_code = gcr.gcry_pk_sign(&sig_s_exp, data_s_exp, self._sec_key_exp)
            GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

            r = GM_T_0003_2_SM2.extract_s_exp_mpi(sig_s_exp, self._SIGNATURE_R_, len(self._SIGNATURE_R_), 1)
            s = GM_T_0003_2_SM2.extract_s_exp_mpi(sig_s_exp, self._SIGNATURE_S_, len(self._SIGNATURE_S_), 1)

            return r, s

#             " ====================== DEBUG SIGN-SELF GENERATED START ======================="
#             print(f" ========================= DEBUG SIGN-SELF GENERATED START =========================")

#             size = gcr.gcry_sexp_sprint (sig_s_exp, gcr.gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, NULL, 0)
#             ch_buf = cython.cast(cython.p_char, malloc(size + 5))

#             size = gcr.gcry_sexp_sprint (sig_s_exp, gcr.gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, ch_buf, size + 5)
#             print(f" SIGNATURE S-EXPRESS <{size}> {cython.cast(bytes, ch_buf)}")

#             free (ch_buf)

#             print (f"""
# \tSignature: <{len(signature)} bytes> -- {signature.hex().upper()}
# \t    r: <{len(r)} bytes> -- {r.hex().upper()}
# \t    s: <{len(s)} bytes> -- {s.hex().upper()}
# """)

#             pkey_s_exp = GM_T_0003_2_SM2.s_exp_key(True, key =b'\x04' + self._pub_key_octets)
#             err_code = gcr.gcry_pk_verify(sig_s_exp, data_s_exp, pkey_s_exp)
#             if err_code ==0:
#                 print (f"sign() -- on filed pk_verify() signature MATCH!")

#             print(f" ========================= DEBUG SIGN-SELF GENERATED END ===========================")
#             " ====================== DEBUG SIGN-SELF GENERATED END ========================="


        except GcryptException as err:
            raise err

        finally:
            if data_s_exp:
                gcr.gcry_sexp_release(data_s_exp)

            if sig_s_exp:
                gcr.gcry_sexp_release(sig_s_exp)


    def _Za(self, id :str='1234567812345678'):
            _id_bits = len(id) * 8
            _id_bytes = id.encode('utf-8')
            
            if _id_bits < 0x0100:
                _id_bits_bin_int = b'\x00' + _id_bits.to_bytes()
            else:
                _id_bits_bin_int = _id_bits.to_bytes()

            _Za = _id_bits_bin_int + \
                _id_bytes + \
                bytes.fromhex(self.ecc_sm2p256v1['a']) + \
                bytes.fromhex(self.ecc_sm2p256v1['b']) + \
                bytes.fromhex(self.ecc_sm2p256v1['Gx']) + \
                bytes.fromhex(self.ecc_sm2p256v1['Gy']) + \
                self._Qa

            return _Za


    cdef bytes sm3_hash(self, buffs: tuple[bytes]=None):
        cdef gcr.gcry_error_t err_code = 0

        cdef int buffcnt = len(buffs)

        cdef int hash_len = gcr.gcry_md_get_algo_dlen(gcr.gcry_md_algos.GCRY_MD_SM3)
        cdef cython.p_uchar digest = cython.cast(cython.p_uchar, malloc(hash_len))
        if digest == NULL:
            raise MemoryError("MemoryError: not able to allocate memory for hash")

        cdef gcr.gcry_buffer_t *iovs = <gcr.gcry_buffer_t *>malloc(buffcnt * cython.sizeof(gcr.gcry_buffer_t))
        if iovs == NULL:
            raise MemoryError("MemoryError: not able to allocate memory for hash")

        for i in range(buffcnt):
            iovs[i].size = len(buffs[i])
            iovs[i].off = 0
            iovs[i].len = len(buffs[i])
            iovs[i].data = cython.cast(cython.p_uchar, buffs[i])

        try:
            err_code = gcr.gcry_md_hash_buffers(gcr.gcry_md_algos.GCRY_MD_SM3, 0, digest, iovs, buffcnt)
            GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

# #####
#             " ==== Single buffer version. ===="
#             gcr.gcry_md_hash_buffer(gcr.gcry_md_algos.GCRY_MD_SM3, digest, cython.cast(cython.p_uchar, data), data_len)
# #####
            hash_bytes = digest[ : hash_len]

            return hash_bytes

        finally:
            if digest:
                free(digest)

            if iovs:
                free(iovs)


    def sing_hash_sm3(self, data: bytes) -> tuple[bytes]:
        """
            a) _Z = SM3 [ENTLA || IDa || a || b || Gx ||Gy || Qx || Qy]。
                - ENTLA : length of IDa in bits (when IDa is default value, it equals to 0x0080 (128 bits))
                - IDa   : Specified id, default to '12345657812345678' (16 bytes/128 bits)
                - a, b  : factors from ECC Curve sm2p256v1 
                - G, Q  : Points on Curve (x-coord | y-coord of BASE POINT and PUBLIC KEY)
            b) SM3 HASH : _e := SM3 [_Za]
            c) SM3 HASH : h := SM3 [_e||MSG]
            d) Signature: Sign(SK)[h] => S := r||s 
        """
        try:
            _Ha = self.sm3_hash(buffs =(self._e, data))
            
            # print(f"Hashed, Digest: '{_Ha.hex().upper()}';  (@sing_hash_sm3())")

            return self.sign(data =_Ha)

        except GcryptException as err:
            raise err

    def decrypt(self, c1 :Union[str, bytes]=None, c2 :Union[str, bytes]=None, c3 :Union[str, bytes]=None) -> bytes:

        """
            !!!CAUTION!!! : 
                THIS FUNCTION HAS NOT BEEN WELL DESINED (and/or) FULLY TESTED. 
                DEBUG BEFORE INVOKE.
        """
        cdef gcr.gcry_error_t err_code = 0

        cdef gcr.gcry_sexp_t cipher_s_exp = NULL
        cdef gcr.gcry_sexp_t plain_s_exp = NULL

        cdef const char *plain_data = NULL
        cdef size_t data_len = 0, data_cnt = 2
# #####
#         cdef char *buffer = <char *>malloc(8192)
# #####
        try:
            cipher_s_exp = GM_T_0003_2_SM2.s_exp_cipher(c1=c1, c2=c2, c3=c3)

            err_code = gcr.gcry_pk_decrypt(&plain_s_exp, cipher_s_exp, self._sec_key_exp)
            GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

            data_cnt = gcr.gcry_sexp_length (plain_s_exp)
            plain_data = gcr.gcry_sexp_nth_data(plain_s_exp, data_cnt - 1, &data_len)

            return cython.cast(bytes, plain_data[:data_len])
# #####
#             print(f"  ============== DEBUG Decryption START ==============")
#             print(plain_data)

#             gcr.gcry_sexp_sprint(plain_s_exp, gcr.gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, buffer, 8192)

#             s_exp_bin = cython.cast(bytes, buffer[:256])
#             s_exp_str = s_exp_bin

#             free(buffer)

#             print(f"Plain text in string : {s_exp_str}")
#             print(f"  ============== DEBUG Decryption ENDED ==============")
#             return GM_T_0003_2_SM2.extract_s_exp_data(cipher_s_exp, self._PLAIN_TXT_, len(self._PLAIN_TXT_), 1)
# #####

        finally:

            if cipher_s_exp:
                gcr.gcry_sexp_release(cipher_s_exp)

            if plain_s_exp:
                gcr.gcry_sexp_release(plain_s_exp)



    def encrypt(self, data :Union[str, bytes]=None) -> tuple[bytes]:
        """
            ciphertext = "(enc-val (flags sm2) (sm2 (a #..hex130...#) (b #..hex64...#) (c #..hex38...#)))"
        """
        cdef gcr.gcry_error_t err_code = 0

        cdef gcr.gcry_sexp_t plain_txt_s_exp = NULL
        cdef gcr.gcry_sexp_t cipher_s_exp = NULL
# #####
#         cdef gcr.gcry_sexp_t cipher_s_exp_dbg = NULL
#         cdef gcr.gcry_sexp_t plain_s_exp = NULL
#         cdef char *buffer = <char *>malloc(2048)
# #####
        try:
            # print(f"Encryting data: '{data.hex().upper() if isinstance(data, bytes) else data}';  (@encrypt())")

            plain_txt_s_exp = GM_T_0003_2_SM2.s_exp_data(data=data)

            err_code = gcr.gcry_pk_encrypt(&cipher_s_exp, plain_txt_s_exp, self._pub_key_exp)
            GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

# #####
#             print(f"  ============== DEBUG Encryption START ==============\n")
#             err_code = gcr.gcry_pk_encrypt(&cipher_s_exp_dbg, plain_txt_s_exp, self._a_pub_key_s_exp)
#             GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

#             gcr.gcry_sexp_sprint(cipher_s_exp_dbg, gcr.gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, buffer, 2048)

#             s_exp_bin = cython.cast(bytes, buffer)
#             s_exp_str = s_exp_bin.decode('utf-8')

#             print(f"Cipher text in string : {s_exp_str}")
#             print(f"  ==============  Encryption/Decryption  ==============\n")

#             err_code = gcr.gcry_pk_decrypt(&plain_s_exp, cipher_s_exp_dbg, self._a_sec_key_s_exp)
#             GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

#             gcr.gcry_sexp_sprint(plain_s_exp, gcr.gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, buffer, 2048)

#             s_exp_bin = cython.cast(bytes, buffer[:strlen(buffer)])
#             s_exp_str = s_exp_bin.decode('utf-8')

#             free(buffer)
#             gcr.gcry_sexp_release(cipher_s_exp_dbg)

#             print(f"Plain text in string : {s_exp_str}")
#             print(f"  ============== DEBUG Decryption ENDED ==============\n")
# #####

            c1 = GM_T_0003_2_SM2.extract_s_exp_data(cipher_s_exp, self._CIPHER_C1_, len(self._CIPHER_C1_), 1)
            c2 = GM_T_0003_2_SM2.extract_s_exp_data(cipher_s_exp, self._CIPHER_C2_, len(self._CIPHER_C2_), 1)
            c3 = GM_T_0003_2_SM2.extract_s_exp_data(cipher_s_exp, self._CIPHER_C3_, len(self._CIPHER_C3_), 1)

            return c1, c2, c3
            # return cipher_bytes

        except GcryptException as err:
            raise err

        finally:

            if plain_txt_s_exp:
                gcr.gcry_sexp_release(plain_txt_s_exp)

            if cipher_s_exp:
                gcr.gcry_sexp_release(cipher_s_exp)


    @staticmethod
    def bin_len_to_hex_len(len :int) -> int:
        return len * 2


    @staticmethod
    cdef gcr.gcry_ctx_t create_ecc_context(s_exp :gcr.gcry_sexp_t):
        cdef gcr.gcry_error_t err_code = 0

        cdef gcr.gcry_ctx_t ctx = NULL

        err_code = gcr.gcry_mpi_ec_new(&ctx, s_exp, NULL)
        GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

        return ctx


    @staticmethod
    cdef gcr.gcry_sexp_t get_ecc_param_s_exp(ctx :gcr.gcry_ctx_t):
        cdef gcr.gcry_error_t err_code = 0

        cdef gcr.gcry_sexp_t pubkey_s_exp = NULL
# #####
#         cdef unsigned char *buffer = <unsigned char *>malloc(2048)
# #####
        err_code = gcr.gcry_pubkey_get_sexp(&pubkey_s_exp, gcr.gcry_ecc_ctx_get.GCRY_PK_GET_PUBKEY, ctx)
        GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

# #####
#         print(f"  ============== DEBUG GET_ECC_PUB_KEY START ==============\n")
#         gcr.gcry_sexp_sprint(pubkey_s_exp, gcr.gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, buffer, 2048)

#         s_exp_bin = cython.cast(bytes, buffer)
#         s_exp_str = s_exp_bin.decode('utf-8')

#         print(f"Pub-Key S-Expression text in string : {s_exp_str}")
#         print(f"  ============== DEBUG GET_ECC_PUB_KEY ENDED ==============\n")
# #####

        return pubkey_s_exp


    @staticmethod
    cdef bytes get_q(ecc_ctx :gcr.gcry_ctx_t):
        cdef gcr.gcry_error_t err_code = 0

        cdef gcr.gcry_mpi_point_t point = NULL

        cdef unsigned char *q_x_bin_s = NULL
        cdef unsigned char *q_y_bin_s = NULL

        cdef int infinity = 0

        cdef gcr.gcry_mpi_t affine_coord_x = NULL
        cdef gcr.gcry_mpi_t affine_coord_y = NULL

        cdef cython.size_t coord_x_len = 0, coord_y_len = 0

        try:
            point = gcr.gcry_mpi_ec_get_point('q', ecc_ctx, 1)
            if not point:
                raise GcryptException(f"Context error: No Q point exist.")

            affine_coord_x = gcr.gcry_mpi_new(GM_T_0003_2_SM2._MPI_N_BITS_)
            affine_coord_y = gcr.gcry_mpi_new(GM_T_0003_2_SM2._MPI_N_BITS_)

            infinity = gcr.gcry_mpi_ec_get_affine(affine_coord_x, affine_coord_y, point, ecc_ctx)
            if infinity:
                raise GcryptException(f"Invalid Q-Point: <ECC::ZERO>")

            q_x_bin_s = cython.cast(cython.p_uchar, malloc(GM_T_0003_2_SM2._MPI_N_BITS_))
            q_y_bin_s = cython.cast(cython.p_uchar, malloc(GM_T_0003_2_SM2._MPI_N_BITS_))

            err_code = gcr.gcry_mpi_print(gcr.gcry_mpi_format.GCRYMPI_FMT_USG, q_x_bin_s, GM_T_0003_2_SM2._MPI_N_BITS_, &coord_x_len, affine_coord_x)
            GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

            err_code = gcr.gcry_mpi_print(gcr.gcry_mpi_format.GCRYMPI_FMT_USG, q_y_bin_s, GM_T_0003_2_SM2._MPI_N_BITS_, &coord_y_len, affine_coord_y)
            GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

            point_hex = cython.cast(bytes, q_x_bin_s[ : coord_x_len]) + cython.cast(bytes, q_y_bin_s[ : coord_y_len])

            print(f"A - public key: {point_hex.hex().upper()}")

            return point_hex

        finally:
            if affine_coord_x:
                gcr.gcry_mpi_release(affine_coord_y)

            if affine_coord_x:
                gcr.gcry_mpi_release(affine_coord_x)

            if point:
                gcr.gcry_mpi_point_release(point)

            if q_y_bin_s:
                free(q_y_bin_s)

            if q_x_bin_s:
                free(q_x_bin_s)


    @staticmethod
    cdef void check_err_no_for_exception(error_no :cython.int):
        if error_no:
            description = <bytes>gcr.gcry_strerror(error_no)
            strsource = <bytes>gcr.gcry_strsource(error_no)
            print(f"<C lib-gcrypt error - #{error_no}>: '{description.decode('utf-8')}': @^'{strsource.decode('utf-8')}'.")
            raise GcryptException(f"<C lib-gcrypt error - #{error_no}>: '{description.decode('utf-8')}': @^'{strsource.decode('utf-8')}'.")


    @staticmethod
    cdef bytes extract_s_exp_data(s_exp_dataset :gcr.gcry_sexp_t, token :cython.p_char, tok_len: cython.size_t, list_index :cython.size_t):
        cdef gcr.gcry_error_t err_code = 0

        cdef gcr.gcry_sexp_t tar_s_exp = NULL

        cdef size_t data_len = 0

        try:
            tar_s_exp = gcr.gcry_sexp_find_token(s_exp_dataset, token, tok_len)
            if not tar_s_exp:
                raise GcryptException(f"<error: 'token: {token}' not found in S-Expression (@gcry_sexp_find_token).")

            data_v = gcr.gcry_sexp_nth_data(tar_s_exp, list_index, &data_len)
            if not data_v:
                raise GcryptException(f"List index #{list_index} out of boundary exception. (@gcry_sexp_nth_data)")

            return data_v[ : data_len]

        except GcryptException as err:
            raise err

        finally:

            if tar_s_exp:
                gcr.gcry_sexp_release(tar_s_exp)


    @staticmethod
    cdef bytes extract_s_exp_mpi(s_exp_dataset :gcr.gcry_sexp_t, token :cython.p_char, tok_len: cython.size_t, list_index :cython.size_t):
        cdef gcr.gcry_error_t err_code = 0

        cdef gcr.gcry_sexp_t tar_s_exp = NULL
        cdef gcr.gcry_mpi_t s_exp_mpi = NULL
        cdef unsigned char * ch_buf = NULL

        cdef size_t data_len = 0

        try:
            tar_s_exp = gcr.gcry_sexp_find_token(s_exp_dataset, token, tok_len)
            if not tar_s_exp:
                raise GcryptException(f"<error: #{err_code}>: token: {token} not found in S-Expression (@extract_s_exp_mpi).")

            s_exp_mpi = gcr.gcry_sexp_nth_mpi(tar_s_exp, list_index, gcr.gcry_mpi_format.GCRYMPI_FMT_STD)
            if not s_exp_mpi:
                raise GcryptException(f"List index #{list_index} out of boundary exception. (@extract_s_exp_mpi)")

            err_code = gcr.gcry_mpi_aprint(gcr.gcry_mpi_format.GCRYMPI_FMT_STD, &ch_buf, &data_len, s_exp_mpi)
            GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

            s_exp_data = cython.cast(bytes, ch_buf[:data_len])

# #####
#             print(f"\tS-Expression MPI: <{data_len} bytes> -- {s_exp_data}  \n\t\t HEX: {s_exp_data.hex().upper()}")
#                 raise GcryptException(f"List index #{list_index} out of boundary exception. (@extract_s_exp_mpi)")
# #####
            return s_exp_data

        except GcryptException as err:
            raise err

        finally:
            if s_exp_mpi:
                gcr.gcry_mpi_release(s_exp_mpi)

            if tar_s_exp:
                gcr.gcry_sexp_release(tar_s_exp)

            if ch_buf:
                gcr.gcry_free(ch_buf)



    @staticmethod
    cdef gcr.gcry_sexp_t s_exp_key(pub_key :bool, key :Union[str, bytes]=None):
        cdef gcr.gcry_error_t err_code = 0

        cdef gcr.gcry_sexp_t key_s_exp = NULL
        cdef size_t offset = 0

# #####
#         cdef char *buffer = <char *>malloc(2048)
# #####

        key_hex = GM_T_0003_2_SM2.hex_unified(key)
        # print(f"S-Expresssion - key: '{key_hex}';  (@s_exp_key())")

        s_exp_key = GM_T_0003_2_SM2.s_exp_wrapped(s_value=key_hex)

        s_exp_bin_s = f"({'public-key' if pub_key else 'private-key'} (ecc (curve {GM_T_0003_2_SM2._CANON_NAME_}) ({'q' if pub_key else 'd'} {s_exp_key})))".encode('utf-8')

        err_code = gcr.gcry_sexp_sscan(&key_s_exp, &offset, cython.cast(cython.p_char, s_exp_bin_s), len(s_exp_bin_s))
        GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

# #####
#         print(f"  ============== DEBUG S-EXP KEY START ==============\n")
#         gcr.gcry_sexp_sprint(key_s_exp, gcr.gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, buffer, 2048)

#         s_exp_bin = cython.cast(bytes, buffer[:strlen(buffer)])
#         s_exp_str = s_exp_bin.decode('utf-8')

#         free(buffer)

#         print(f"Plain text in string : {s_exp_str}")
#         print(f"  ============== DEBUG S-EXP KEY ENDED ==============\n")
# #####
        return key_s_exp



    @staticmethod
    cdef gcr.gcry_sexp_t s_exp_signature(sig :Union[str, bytes]=None):
        cdef gcr.gcry_error_t err_code = 0

        cdef gcr.gcry_sexp_t sig_s_exp = NULL
        cdef size_t offset = 0

        hex = GM_T_0003_2_SM2.hex_unified(_in_d =sig)
        if len(hex) != 128:
            raise GcryptException(f"Signature verify error. \n {hex} is not a valid SM2 Signature.")

        bigint_hex_len = GM_T_0003_2_SM2.bin_len_to_hex_len(32)

        r_hex = hex[:bigint_hex_len]
        s_hex = hex[bigint_hex_len:]

        # print(f"Signature S-Expresssion - Signature, r: '{r_hex}', s: '{s_hex}';  (@s_exp_signature())")

        r_exp_v = GM_T_0003_2_SM2.s_exp_wrapped(s_value=r_hex)
        s_exp_v = GM_T_0003_2_SM2.s_exp_wrapped(s_value=s_hex)

        s_exp_bin_s = f"(sig-val (sm2 (r {r_exp_v}) (s {s_exp_v})))".encode('utf-8')


        err_code = gcr.gcry_sexp_sscan(&sig_s_exp, &offset, cython.cast(cython.p_char, s_exp_bin_s), len(s_exp_bin_s))
        GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

        return sig_s_exp


    @staticmethod
    cdef gcr.gcry_sexp_t s_exp_data(data :Union[str, bytes]=None):
        cdef gcr.gcry_error_t err_code = 0

        cdef gcr.gcry_sexp_t data_s_exp = NULL
        cdef size_t offset = 0
#####
        # cdef size_t size = 0
#####

        data_hex = GM_T_0003_2_SM2.hex_unified(data)

        # print(f"Data S-Expresssion - data: '{data_hex}';  (@s_exp_data())")

        s_exp_v = GM_T_0003_2_SM2.s_exp_wrapped(s_value=data_hex)
        s_exp_bin_s = f"(data (flags sm2) (value {s_exp_v}))".encode('utf-8')


        err_code = gcr.gcry_sexp_sscan(&data_s_exp, &offset, cython.cast(cython.p_char, s_exp_bin_s), len(s_exp_bin_s))
        GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

#####

        # size = gcr.gcry_sexp_sprint (data_s_exp, gcr.gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, NULL, 0)
        # ch_buf = cython.cast(cython.p_char, malloc(size + 5))

        # size = gcr.gcry_sexp_sprint (data_s_exp, gcr.gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, ch_buf, size + 5)
        # print(f" DATA S-EXPRESS <{size}> {cython.cast(bytes, ch_buf)}")

        # free (ch_buf)
#####
        return data_s_exp


    @staticmethod
    cdef gcr.gcry_sexp_t s_exp_cipher(c1 :Union[str, bytes]=None, c2 :Union[str, bytes]=None, c3 :Union[str, bytes]=None):
        cdef gcr.gcry_error_t err_code = 0

        cdef gcr.gcry_sexp_t cipher_s_exp = NULL
        cdef size_t offset = 0
# ####
#         cdef size_t size = 0
# ####

        c1_hex = GM_T_0003_2_SM2.hex_unified(c1)
        c2_hex = GM_T_0003_2_SM2.hex_unified(c2)
        c3_hex = GM_T_0003_2_SM2.hex_unified(c3)

        c1_s_exp_v = GM_T_0003_2_SM2.s_exp_wrapped(s_value=c1_hex)
        c2_s_exp_v = GM_T_0003_2_SM2.s_exp_wrapped(s_value=c2_hex)
        c3_s_exp_v = GM_T_0003_2_SM2.s_exp_wrapped(s_value=c3_hex)

        s_exp_bin_s = f"""(enc-val 
 (flags sm2)
 (sm2 
  (a {c1_s_exp_v})
  (b {c2_s_exp_v})
  (c {c3_s_exp_v})
  )
 )""".encode('utf-8')

        err_code = gcr.gcry_sexp_sscan(&cipher_s_exp, &offset, cython.cast(cython.p_char, s_exp_bin_s), len(s_exp_bin_s))
        GM_T_0003_2_SM2.check_err_no_for_exception(err_code)

# #####

#         size = gcr.gcry_sexp_sprint (cipher_s_exp, gcr.gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, NULL, 0)
#         ch_buf = cython.cast(cython.p_char, malloc(size + 5))

#         size = gcr.gcry_sexp_sprint (cipher_s_exp, gcr.gcry_sexp_format.GCRYSEXP_FMT_ADVANCED, ch_buf, size + 5)
#         print(f" DATA S-EXPRESS <{size}> {cython.cast(bytes, ch_buf)}")

#         free (ch_buf)
# #####
        return cipher_s_exp


    @staticmethod
    def hex_unified(_in_d: Union[str, bytes]) -> str:
        if isinstance(_in_d, bytes):
            return _in_d.hex()
        else:
            return _in_d


    @staticmethod
    def binary_unified(_in_d: Union[str, bytes]) -> bytes:
        if isinstance(_in_d, bytes):
            return _in_d
        else:
            return bytes.fromhex(_in_d)


    @staticmethod
    def s_exp_wrapped(s_value :Union[str, bytes]=None) -> str:

        return f"#{GM_T_0003_2_SM2.hex_unified(s_value)}#"


