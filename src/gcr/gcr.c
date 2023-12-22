#if PY_MAJOR_VERSION < 3
# define MODINIT(name)  init ## name
#else
# define MODINIT(name)  PyInit_ ## name
#endif

// PyMODINIT_FUNC  MODINIT(some_module_name) (void);

PyMODINIT_FUNC  MODINIT("s_exp") (void);
PyMODINIT_FUNC  MODINIT("cerr") (void);
PyMODINIT_FUNC  MODINIT("mpi") (void);