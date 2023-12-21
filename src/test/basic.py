# print(f"Programe entry point: file: {__file__}; name: {__name__}; package: {__package__}")

from ..gcr.pygcr.s_exp import SymbolicExpression


try:
    s_exp = SymbolicExpression('(a b (c d) ((e f) g h))')

    assert s_exp.car
    assert s_exp.cdr
except:
    pass
finally:
    pass
