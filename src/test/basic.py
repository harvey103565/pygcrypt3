
from .s_exp import symbolic_expression_creating_test, \
                   symbolic_expression_partial_exp_test, \
                   symbolic_expression_nested_exp_test, \
                   symbolic_expression_multiple_level_exp_test

from ..gcr.s_exp import SymbolicExpression

try:
    print("\n=====Test case 1/38 =====.\n")
    symbolic_expression_creating_test()

    print("\n=====Test case 2/38 =====.\n")
    symbolic_expression_partial_exp_test()
    
    print("\n=====Test case 3/38 =====.\n")
    symbolic_expression_nested_exp_test()
    
    print("\n=====Test case 4/38 =====.\n")
    symbolic_expression_multiple_level_exp_test()


    s_exp = SymbolicExpression(b'(a brown (fox jumping) ((lazy dog) over the))')

    print(str(s_exp))
    print(repr(s_exp))

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

    print("Iteration test - trade s-exp as list.")

    for exp in s_exp:
        assert isinstance(exp, SymbolicExpression)
        for sub_exp in exp:
            print(f"{exp} - {sub_exp}")

    print("Indexability test - trade s-exp as list.")
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
    print("ALL test case done.")
