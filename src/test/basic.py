from ..gcr import gcr_demo
from ..gcr.s_exp import SymbolicExpression

try:
    s_exp = SymbolicExpression('(a b (c d) ((e f) g h))')

    # basic function
    assert s_exp.car
    assert s_exp.cdr

    car = s_exp.car
    cdr = s_exp.cdr

    assert isinstance(car, SymbolicExpression)
    assert isinstance(cdr, SymbolicExpression)

    assert car.data == b'a'
    assert cdr.data == b'b'

    assert len(car) == 1
    assert len(cdr) == 1

    assert len(s_exp) == 4

    # Indexability
    for i in range(len(s_exp)):
        sub_s_exp = s_exp[i]
        assert isinstance(sub_s_exp, SymbolicExpression)

        if len(sub_s_exp) == 1:
            assert len(sub_s_exp.data) == 1
        else:
            assert isinstance(sub_s_exp, SymbolicExpression)

     
    
except Exception as e:
    print(e)
finally:
    pass

print("ALL test case done.")