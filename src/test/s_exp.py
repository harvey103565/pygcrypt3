from ..gcr.s_exp import SymbolicExpression


def symbolic_expression_creating_test():

    print("1-1. Creating symbolic expression from empty list, exception expected.")
    try:
        SymbolicExpression(b'()')
    except:
        print("Exception caught. -- PASS")
    else:
        raise Exception("Empty lists-exp test failed.")
    
    print("1-2.  Creating symbolic expression from atom data, exception expected.")
    try:
        SymbolicExpression(b'a')
    except:
        print("Exception caught. -- PASS")
    else:
        raise Exception("Non-parenthesized atom data test failed.")
    
    print("1-3.  Creating symbolic expression from mal-formatted string, exception expected.")
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

    print(f"2-4.  Get data with indexing. got: '{repr(s_exp)}'")
    assert s_exp[0] == b'a', "Read invalid data with 's_exp[0]'"
    
    print(f"2-5.  Access inner list with attribute name, exception expected.")
    try: 
        sub_exp = str(s_exp.a)
    except Exception as e:
        print("Exception caught. -- PASS")

    print(f"2-6.  Access car expression, got '{str(s_exp.car)}'.")
    s_car = s_exp.car

    print(f"2-7.  Assert! car expression should be atom type.")
    assert s_car.is_atom(), "Expression should be atom, but it's not."

    print(f"2-8.  Assert! data() from atom expression should equal b'a'.")
    assert s_car.data() == b'a', "Expression data should be equivenlate to b'a', but it's not."


def symbolic_expression_nested_exp_test():

    s_exp = SymbolicExpression(b'(a (b c) d)')
    print(f"3-1.  Test accessibility for nested expression: '{repr(s_exp)}'.")
    
    print(f"3-2.  Assert! data() for should equal b'a'.")
    assert s_exp.car.data() == b'a', "Expression data should be equivenlate to b'a', but it's not."

    print(f"3-3.  Assert! cdr expression should not be atom type.")
    assert not s_exp.cdr.is_atom(), "Expression should not be atom, but it is."
    
    print(f"3-4.  Cdr for expresion is: '{repr(s_exp.cdr)}'")


def symbolic_expression_multiple_level_exp_test():

    s_exp = SymbolicExpression(b'((a c) b (d (e f)))')
    print(repr(s_exp))
    print(f"s_exp[1]={s_exp[1]}")
    s_car = s_exp.cdr
    print(f"s_exp[0]={s_car[0]}")
    print(f"s_exp[1]={s_car[1]}")


    s_cdr = s_exp.cdr
    print(str(s_cdr))
    assert s_cdr.is_atom()
    assert s_cdr.data == b'b'

