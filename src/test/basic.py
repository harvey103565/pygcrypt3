
from ..gcr.s_exp import SymbolicExpression

try:
    s_exp = SymbolicExpression('(a b (c d) ((e f) g h))')

    assert s_exp.car
    assert s_exp.cdr

    car = s_exp.car
    cdr = s_exp.cdr

    assert isinstance(car, SymbolicExpression)
    assert isinstance(cdr, SymbolicExpression)

    
except Exception as e:
    print(e)
finally:
    pass

print("ALL test case done.")