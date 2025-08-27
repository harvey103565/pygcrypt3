

class GcrError(Exception):
    pass

class GcrSexpError(GcrError):
    pass

class GcrSexpNilError(GcrSexpError):
    pass

class GcrSexpFormatError(GcrSexpError):
    pass

class GcrSexpOutOfBoundaryError(GcrSexpError):
    pass