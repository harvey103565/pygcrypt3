from ..gcr.s_exp import SymbolicExpression


def symbolic_expression_creating_test():

    print("1-1. Creating symbolic expression from empty list.")
    try:
        SymbolicExpression(b'()')
    except:
        print("Exception caught. -- PASS")
    else:
        raise Exception("Empty lists-exp test failed.")
    
    print("1-2.  Creating symbolic expression from atom data.")
    try:
        SymbolicExpression(b'a')
    except:
        print("Exception caught. -- PASS")
    else:
        raise Exception("Non-parenthesized atom data test failed.")
    
    print("1-3.  Creating symbolic expression from mal-formatted string.")
    try:
        SymbolicExpression(b'(a')
    except:
        print("Exception caught. -- PASS")
    else:
        raise Exception("Malformatted string test failed.")

def symbolic_expression_partial_exp_test():
    
    print("2-1.  Creating symbolic expression from '(a . nil)'.")
    s_exp = SymbolicExpression(b'(a)')
    
    print(f"2-2.  Get read friendly string from '(a . nil)'. got: '{str(s_exp)}'")

    print(f"2-3.  Get canoncial string from '(a . nil)'. got: '{repr(s_exp)}'")

    print(f"2-4.  Get canoncial string from '(a . nil)'. got: '{repr(s_exp)}'")
    assert s_exp[0] == b'a', f"Read invalid data from '(a . nil)'"
    
    try: 
        print(str(s_exp.a))
    except Exception as e:
        assert s_exp.data() == b'a'

    s_car = s_exp.car
    print(str(s_car))
    assert s_car.is_atom()
    assert s_car.data == b'a'
