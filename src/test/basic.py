from ..gcr import gcr_demo
from ..gcr.s_exp import SymbolicExpression

try:
    s_exp = SymbolicExpression('(a b (c d) ((e f) g h))')

    # basic function
    assert s_exp.car
    assert s_exp.cdr

    car = s_exp.car
    cdr = s_exp.cdr

    assert isinstance(car, bytes)
    assert isinstance(cdr, bytes)

    assert car == b'a'
    assert cdr == b'b'

    assert len(car) == 1
    assert len(cdr) == 1

    assert len(s_exp) == 4

    for exp in s_exp:
        assert isinstance(exp, SymbolicExpression)
        for sub_exp in exp:
            print(f"{exp} - {sub_exp}")

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