# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

cdef extern from "gpg-error.h":

    ctypedef unsigned int gpg_error_t


cdef extern from "gcrypt.h":

    ctypedef gpg_error_t gcry_error_t

    ctypedef struct gcry_buffer:
        size_t size
        size_t off
        size_t len
        void *data

    ctypedef gcry_buffer* gcry_buffer_t

    const char *gcry_strerror (gcry_error_t err)

    const char *gcry_strsource (gcry_error_t err)

