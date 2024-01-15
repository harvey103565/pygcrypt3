# cython: c_string_type=unicode, c_string_encoding=utf8
# cython: language_level=3

from .gcry_comm cimport gcry_error_t, gcry_buffer_t, gpg_error_t
from .gcry_comm cimport gcry_sexp_t
from .gcry_mpi cimport gcry_mpi_t

ctypedef unsigned char * s_exp_str_t


cdef extern from "gcrypt.h":


    ctypedef void (* p_freefnc) (void* )

    cdef enum gcry_sexp_format:
        GCRYSEXP_FMT_DEFAULT   = 0,
        GCRYSEXP_FMT_CANON     = 1,
        GCRYSEXP_FMT_BASE64    = 2,
        GCRYSEXP_FMT_ADVANCED  = 3


    # """
    # -----
    # Functions to create an Libgcrypt S-expression object from its external representation or from a string template. 
    # -----
    # """

    # """
    # Create an new S-expression object from its external representation in 'buffer' of 'length' bytes. 
    # On success the result is stored at the address given by 'r_sexp'. 
    # With 'autodetect' set to 0, the data in buffer is expected to be in canonized format, 
    # with 'autodetect' set to 1 the function parses any of the defined external formats. 
    # If buffer does not hold a valid S-expression, an error code is returned and 'r_sexp' set to NULL. 
    # ** NOTE ** that the caller is responsible for releasing the newly allocated S-expression using gcry_sexp_release.
    # """
    gcry_error_t gcry_sexp_new (gcry_sexp_t *r_sexp, const void *buffer, size_t length, int autodetect)

    # """
    # Identical to gcry_sexp_new but has an extra argument freefnc, which, when not set to NULL, is expected to be a function to release the buffer; 
    # (most likely the standard free function is used for this argument. )
    # This has the effect of transferring the ownership of buffer to the created object in r_sexp. 
    # The advantage of using this function is that Libgcrypt might decide to directly use the provided buffer and thus avoid extra copying.
    # """
    gcry_error_t gcry_sexp_create (gcry_sexp_t *r_sexp, void *buffer, size_t length, int autodetect, p_freefnc)
    
    # """
    # Identical to gcry_sexp_create but provides an erroff argument which will receive the offset into the buffer where the parsing stopped on error.
    # """
    gcry_error_t gcry_sexp_sscan (gcry_sexp_t *r_sexp, size_t *erroff, const char *buffer, size_t length)
 
    # """
    # his function creates an internal S-expression from the string template format and stores it at the address of r_sexp. 
    # If there is a parsing error, the function returns an appropriate error code and stores the offset into format where the parsing stopped in erroff. 
    # The function supports a couple of printf-like formatting characters and expects arguments for some of these escape sequences right after format. 
    # The following format characters are defined:
	#	- ‘%m’: to be of type gcry_mpi_t and a copy of its value is inserted into the resulting S-expression. The MPI is stored as a signed integer.
	#	- ‘%M’: to be of type gcry_mpi_t and a copy of its value is inserted into the resulting S-expression. The MPI is stored as an unsigned integer.
	#	- ‘%s’: to be of type char * and that string is inserted into the resulting S-expression.
	#	- ‘%d’: to be of type int and its value is inserted into the resulting S-expression.
	#	- ‘%u’: to be of type unsigned int and its value is inserted into the resulting S-expression.
	#	- ‘%b’: to be of type int directly followed by an argument of type char *. This represents a buffer of given length to be inserted into the resulting S-expression.
	#	- ‘%S’: to be of type gcry_sexp_t and a copy of that S-expression is embedded in the resulting S-expression. The argument needs to be a regular S-expression, starting with a parenthesis.
    # No other format characters are defined and would return an error. 
    # ** NOTE ** that the format character ‘%%’ does not exists, because a percent sign is not a valid character in an S-expression.
    # """
    gcry_error_t gcry_sexp_build (gcry_sexp_t *r_sexp, size_t *erroff, const char *format, ...)

    # """
    # Release the S-expression object sexp. If the S-expression is stored in secure memory, it explicitly zeroises that memory; 
    # ** NOTE ** that this is done in addition to the zeroisation always done when freeing secure memory.
    # """
    void gcry_sexp_release (gcry_sexp_t sexp)

    
 
    # """
    # -----
    # Functions used to convert the internal representation back into a regular external S-expression format and to show the structure for debugging.
    # -----
    # """

    # """
    # Copies the S-expression object sexp into buffer using the format specified in mode. maxlength must be set to the allocated length of buffer. 
    # The function returns the actual length of valid bytes put into buffer or 0 if the provided buffer is too short. 
    # Passing NULL for buffer returns the required length for buffer. 
    # ** NOTE ** For convenience reasons an extra byte with value 0 is appended to the buffer.
    # The following formats are supported:
    #   GCRYSEXP_FMT_DEFAULT: Returns a convenient external S-expression representation.
    #   GCRYSEXP_FMT_CANON: Return the S-expression in canonical format.
    #   ** GCRYSEXP_FMT_BASE64: <Not currently supported>.
    #   GCRYSEXP_FMT_ADVANCED: Returns the S-expression in advanced format.
    # """
    size_t gcry_sexp_sprint (gcry_sexp_t sexp, int mode, char *buffer, size_t maxlength)

    # """
    # Dumps sexp in a format suitable for debugging to Libgcrypt’s logging stream.
    # """
    void gcry_sexp_dump (gcry_sexp_t sexp)

    # """
    # Often canonical encoding is used in the external representation. The following function can be used to check for valid encoding and to learn the length of the S-expression.
    # """
    size_t gcry_sexp_canon_len (const unsigned char *buffer, size_t length, size_t *erroff, int *errcode)


    # """
    # -----
    # Functions to parse S-expressions and retrieve elements:
    # -----
    # """

    # """
    # Scan the S-expression for a sublist with a type (the car of the list) matching the string token. 
    # If 'toklen' is not 0, the token is assumed to be raw memory of this length. 
    # The function returns a newly allocated S-expression consisting of the found sublist or NULL when not found.
    # ** NOTE ** The caller is responsible for releasing the newly allocated S-expression using gcry_sexp_release.
    # """
    gcry_sexp_t gcry_sexp_find_token (const gcry_sexp_t list, const char *token, size_t toklen)

    # """
    # Return the length of the list. For a valid S-expression this should be at least 1.
    # """
    int gcry_sexp_length (const gcry_sexp_t list)

    # """
    # Create and return a new S-expression from the element with index number in list. Note that the first element has the index 0. 
    # If there is no such element, NULL is returned.
    # ** NOTE ** The caller is responsible for releasing the newly allocated S-expression using gcry_sexp_release.
    # """
    gcry_sexp_t gcry_sexp_nth (const gcry_sexp_t list, int number)

    # """
    # Create and return a new S-expression from the first element in list; this is called the "type" and should always exist per S-expression specification and in general be a string. 
    # NULL is returned in case of a problem.
    # ** NOTE ** The caller is responsible for releasing the newly allocated S-expression using gcry_sexp_release.
    # """
    gcry_sexp_t gcry_sexp_car (const gcry_sexp_t list)

    # """
    # Create and return a new list form all elements except for the first one. 
    # Note that this function may return an invalid S-expression because it is not guaranteed that the type exists and is a string. 
    # However, for parsing a complex S-expression it might be useful for intermediate lists. Returns NULL on error.
    # ** NOTE ** The caller is responsible for releasing the newly allocated S-expression using gcry_sexp_release.
    # """
    gcry_sexp_t gcry_sexp_cdr (const gcry_sexp_t list)

    # """
    # This function is used to get data from a list. A pointer to the actual data with index number is returned and the length of this data will be stored to datalen. 
    # If there is no data at the given index or the index represents another list, NULL is returned. Caution: The returned pointer is valid as long as list is not modified or released.
    # Here is an example on how to extract and print the surname (Meier) from the S-expression ‘(Name Otto Meier (address Burgplatz 3))’:
    #    size_t len;
    #    const char *name;
    #    name = gcry_sexp_nth_data (list, 2, &len);
    #    printf ("my name is %.*s\n", (int)len, name);
    # """
    const char * gcry_sexp_nth_data (const gcry_sexp_t list, int number, size_t *datalen)

    # """
    # This function is used to get data from a list. A malloced buffer with the actual data at list index number is returned and the length of this buffer will be stored to rlength. 
    # If there is no data at the given index or the index represents another list, NULL is returned. The caller must release the result using gcry_free.
	# Here is an example on how to extract and print the CRC value from the S-expression ‘(hash crc32 #23ed00d7)’:
	# 	size_t len;
	# 	char *value;
	# 	value = gcry_sexp_nth_buffer (list, 2, &len);
	# 	if (value)
	# 	  fwrite (value, len, 1, stdout);
	# 	gcry_free (value);
    # """
    void * gcry_sexp_nth_buffer (const gcry_sexp_t list, int number, size_t *rlength)

    # """
    # This function is used to get and convert data from a list. The data is assumed to be a Nul terminated string. The caller must release this returned value using gcry_free. 
    # If there is no data at the given index, the index represents a list or the value can’t be converted to a string, NULL is returned.
    # """
    char * gcry_sexp_nth_string (gcry_sexp_t list, int number)

    # """
    # This function is used to get and convert data from a list. This data is assumed to be an MPI stored in the format described by mpifmt and returned as a standard Libgcrypt MPI. 
    # If there is no data at the given index, the index represents a list or the value can’t be converted to an MPI, NULL is returned. 
    # If you use this function to parse results of a public key function, you most likely want to use GCRYMPI_FMT_USG.
    # ** NOTE ** The caller must release this returned value using gcry_mpi_release. 
    # """
    gcry_mpi_t gcry_sexp_nth_mpi (gcry_sexp_t list, int number, int mpifmt)

    # """
    # Extract parameters from an S-expression using a list of parameter names. The names of these parameters are specified in list. 
    # White space between the parameter names are ignored. Some special characters and character sequences may be given to control the conversion:
    # 	‘+’:    Switch to unsigned integer format (GCRYMPI_FMT_USG). This is the default mode.
    # 	‘-’:    Switch to standard signed format (GCRYMPI_FMT_STD).
    # 	‘/’:    Switch to opaque MPI format. The resulting MPIs may not be used for computations; see gcry_mpi_get_opaque for details.
    # 	‘&’:    Switch to buffer descriptor mode. See below for details.
    # 	‘%s’:   Switch to string mode. The expected argument is the address of a char * variable; the caller must release that value. If the parameter was marked optional and is not found, NULL is stored.
    # 	‘%#s’:  Switch to multi string mode. The expected argument is the address of a char * variable; the caller must release that value. If the parameter was marked optional and is not found, NULL is stored. A multi string takes all values, assumes they are strings and concatenates them using a space as delimiter. In case a value is actually another list, this is not further parsed but a () is inserted in place of that sublist.
    # 	‘%u’:   Switch to unsigned integer mode. The expected argument is address of a unsigned int variable.
    # 	‘%lu’:  Switch to unsigned long integer mode. The expected argument is address of a unsigned long variable.
    # 	‘%d’:   Switch to signed integer mode. The expected argument is address of a int variable.
    # 	‘%ld’:  Switch to signed long integer mode. The expected argument is address of a long variable.
    # 	‘%zu’:  Switch to size_t mode. The expected argument is address of a size_t variable.
    # 	‘?’:    If immediately following a parameter letter (no white space allowed), that parameter is considered optional.
    # In general, parameter names are single letters. To use a string for a parameter name, enclose the name in single quotes.
    # Unless in buffer descriptor mode, for each parameter name a pointer to an gcry_mpi_t variable is expected that must be set to NULL prior to invoking this function, and finally a NULL is expected. 
    # For example: 
    #   gcry_sexp_extract_param (key, NULL, "n/x+e d-'foo'", &mpi_n, &mpi_x, &mpi_e, &mpi_d, &mpi_foo, NULL)
    #   stores: 
    #       the parameter ’n’ from key as an unsigned MPI into mpi_n, 
    #       the parameter ’x’ as an opaque MPI into mpi_x, 
    #       the parameters ’e’ and ’d’ again as an unsigned MPI into mpi_e and mpi_d 
    #       and finally the parameter ’foo’ as a signed MPI into mpi_foo.
    # path is an optional string used to locate a token. The exclamation mark separated tokens are used via gcry_sexp_find_token to find a start point 
    # inside the S-expression.
    # In buffer descriptor mode a pointer to a gcry_buffer_t descriptor is expected instead of a pointer to an MPI. 
    # The caller may use two different operation modes here: If the data field of the provided descriptor is NULL, 
    # the function allocates a new buffer and stores it at data; the other fields are set accordingly with off set to 0. 
    # If data is not NULL, the function assumes that the data, size, and off fields specify a buffer where to put the value of the respective parameter; 
    # on return the len field receives the number of bytes copied to that buffer; in case the buffer is too small, the function immediately returns 
    # with an error code (and len is set to 0).
    # The function returns 0 on success. On error an error code is returned, all passed MPIs that might have been allocated up to this point are deallocated and set to NULL, and all passed buffers are either truncated if the caller supplied the buffer, or deallocated if the function allocated the buffer.
    # """
    gpg_error_t gcry_sexp_extract_param ( gcry_sexp_t sexp, const char *path, const char *list, ...)
