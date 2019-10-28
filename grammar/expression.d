module grammar.expression;

import compiler.source;
import grammar.lex;
import grammar.qualified;

// 7 Expressions

//expression :
//  simple_expression ( relational_operator simple_expression )?
//  ;

//simple_expression :
//  ( '+' | '-' )? term ( term_operator term )*
//  ;

//term :
//  factor ( factor_operator factor )*
//  ;

//factor :
//  '(' expression ')' |
//  'NOT' factor |
//  value_designator |
//  function_call |
//  value_constructor |
//  constant_literal
//  ;

//ordinal_expression :
//  expression
//  ;

// 7.1 Infix Expressions

//relational_operator :
//  '=' | '#' | '<' | '<=' | '>' | '>=' | 'IN' |
//  ;
// ***** PIM 4 Appendix 1 line 14 *****
//relation :
//  '=' | '#' | '<>' | '<' | '<=' | '>' | '>=' | 'IN' {}
//  ;
private bool relationalOperator(Source source) nothrow in {
    assert(source);
} body {
    consumeWhitespace(source);

    if (consumeLiteral(source, "IN")) return true;
    if (consumeLiteral(source, "<>")) return true;
    if (consumeLiteral(source, "<=")) return true;
    if (consumeLiteral(source, ">=")) return true;

    if (consumeLiteral(source, "=")) return true;
    if (consumeLiteral(source, "#")) return true;
    if (consumeLiteral(source, "<")) return true;

    return false;
}

//term_operator :
//  '+' | '-' | 'OR'
//  ;
// ***** PIM 4 Appendix 1 line 16 *****
//addOperator :
//  '+' | '-' | OR
//  {} // make ANTLRworks display separate branches
//  ;
private bool addOperator(Source source) nothrow in {
    assert(source);
} body {
    consumeWhitespace(source);

    if (consumeLiteral(source, "OR")) return true;

    if (consumeLiteral(source, "+")) return true;
    if (consumeLiteral(source, "-")) return true;

    return false;
}

//factor_operator :
//  '*' | '/' | 'REM' | 'DIV' | 'MOD' | 'AND'
//  ;
// ***** PIM 4 Appendix 1 line 18 *****
//mulOperator :
//  '*' | '/' | DIV | MOD | AND | '&'
//  {} // make ANTLRworks display separate branches
//  ;
private bool mulOperator(Source source) nothrow in {
    assert(source);
} body {
    consumeWhitespace(source);

    if (consumeLiteral(source, "AND")) return true;
    if (consumeLiteral(source, "DIV")) return true;
    if (consumeLiteral(source, "MOD")) return true;
    if (consumeLiteral(source, "REM")) return true;

    if (consumeLiteral(source, "*")) return true;
    if (consumeLiteral(source, "/")) return true;

    return false;
}

// 7.2 Value Designator

//value_designator :
//  entire_value | indexed_value | selected_value | dereferenced_value
//  ;

// 7.2.1 Entire Value

//entire_value :
//  qualified_identifier
//  ;

// 7.2.2 Indexed Value

//indexed_value :
//  array_value '[' index_expression ( ',' index_expression )* ']'
//  ;

//array_value :
//  value_designator
//  ;

// 7.2.3 Selected Value

//selected_value :
//  record_value '.' field_identifier
//  ;

//record_value :
//  value_designator
//  ;

// 7.2.4 Dereferenced Value

//dereferenced_value :
//  pointer_value '^'
//  ;

//pointer_value :
//  value_designator
//  ;

// 7.3 Function Call

//function_call :
//  function_designator actual_parameters
//  ;

//function_designator :
//  value_designator
//  ;

// 7.4 Value Constructors

//value_constructor :
//  array_constructor | record_constructor | set_constructor
//  ;

// 7.4.1 Array Constructor

//array_constructor :
//  array_type_identifier array_constructed_value
//  ;

//array_type_identifier :
//  type_identifier;

//array_constructed_value :
//  '{' repeated_structure_component ( ',' repeated_structure_component )* '}'
//  ;

//repeated_structure_component :
//  structure_component ( 'BY' repetition_factor )?
//  ;

//repetition_factor :
//  constant_expression
//  ;

//structure_component :
//  expression | array_constructed_value | record_constructed_value |
//  set_constructed_value
//  ;

// 7.4.2 Record Constructor

//record_constructor :
//  record_type_identifier record_constructed_value
//  ;

//record_type_identifier :
//  type_identifier
//  ;

//record_constructed_value :
//  '{' ( structure_component )? ( ',' structure_component )* '}'
//  ;

// 7.4.3 Set Constructor

//set_constructor :
//  set_type_identifier set_constructed_value
//  ;

//set_type_identifier :
//  type_identifier
//  ;

//set_constructed_value :
//  '{' ( member  ( ',' member )* )? '}'
//  ;

//member :
//  interval | singleton
//  ;

//interval :
//  ordinal_expression '..' ordinal_expression
//  ;

//singleton :
//  ordinal_expression
//  ;

// 7.5 Constant Literal

//constant_literal :
//  whole_number_literal | real_literal | string_literal | pointer_literal
//  ;

// 7.6 Constant Expression

//constant_expression :
//  expression
//  ;
// ***** PIM 4 Appendix 1 line 13 *****
//constExpression :
//  simpleConstExpr ( relation simpleConstExpr )?
//  ;
public bool constantExpression(Source source) nothrow in {
    assert(source);
} body {
    if (!simpleConstExpression(source)) return false;

    while (true) {
        source.bookmark();

        if (!relationalOperator(source)) {
            source.rollback();
            break;
        }

        if (!simpleConstExpression(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}

// ***** PIM 4 Appendix 1 line 15 *****
//simpleConstExpr :
//  ( '+' | '-' {})? constTerm ( addOperator constTerm )*
//  ;
private bool simpleConstExpression(Source source) nothrow in {
    assert(source);
} body {
    consumeWhitespace(source);
    if (!consumeLiteral(source, "+")) {
        consumeLiteral(source, "-");
    }

    if (!constTerm(source)) return false;

    while (true) {
        source.bookmark();

        if (!addOperator(source)) {
            source.rollback();
            break;
        }

        if (!constTerm(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}

// ***** PIM 4 Appendix 1 line 17 *****
//constTerm :
//  constFactor ( mulOperator constFactor )*
//  ;
private bool constTerm(Source source) nothrow in {
    assert(source);
} body {
    if (!constFactor(source)) return false;

    while (true) {
        source.bookmark();

        if (!mulOperator(source)) {
            source.rollback();
            break;
        }

        if (!constFactor(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}

// ***** PIM 4 Appendix 1 lines 19-20 *****
// refactored for LL(1)
//
// Note: PIM 4 text says '~' is a synonym for 'NOT'
//       but the grammar does not actually show it
//constFactor :
//  number | string | setOrQualident |
//  '(' constExpression ')' | ( NOT | '~' {}) constFactor
//  ;
private bool constFactor(Source source) nothrow in {
    assert(source);
} body {
    consumeWhitespace(source);

    // number
    if (wholeNumberLiteral(source)) return true;

    // string
    if (stringLiteral(source)) return true;

    // ( constExpression )
    source.bookmark();
    if (consumeLiteral(source, "(")) {
        if (constantExpression(source)) {
            consumeWhitespace(source);
            if (consumeLiteral(source, ")")) {
                source.commit();
            } else {
                source.rollback();
            }
        } else {
            source.rollback();
        }
    } else {
        source.rollback();
    }

    // ( NOT | '~' {}) constFactor
    source.bookmark();
    if (consumeLiteral(source, "NOT") || consumeLiteral(source, "~")) {
        source.commit();
        return constFactor(source);
    } else {
        source.rollback();
    }

    // setOrQualident
    return setOrQualident(source);
}

// ***** PIM 4 Appendix 1 lines 19-20 *****
// new for LL(1)
//setOrQualident :
//  set | qualident set?
//  ;
private bool setOrQualident(Source source) nothrow in {
    assert(source);
} body {
    // qualident set?
    source.bookmark();
    if (qualifiedIdentifier(source)) {
        source.bookmark();
        if (set(source)) {
            source.commit();
        } else {
            source.rollback();
        }

        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return set(source);
}

// ***** PIM 4 Appendix 1 line 21 *****
// refactored for LL(1)
//set :
//  /* qualident has been factored out */
//  '{' ( element ( ',' element )* )? '}'
//  ;
private bool set(Source source) nothrow in {
    assert(source);
} body {
    consumeWhitespace(source);
    if (!consumeLiteral(source, "{")) return false;

    source.bookmark();
    if (element(source)) {
        while (true) {
            source.bookmark();

            consumeWhitespace(source);
            if (!consumeLiteral(source, ",")) {
                source.rollback();
                break;
            }

            if (!element(source)) {
                source.rollback();
                break;
            }

            source.commit();
        }

        source.commit();
    } else {
        source.rollback();
    }

    consumeWhitespace(source);
    return consumeLiteral(source, "}");
}

// ***** PIM 4 Appendix 1 line 22 *****
//element :
//  constExpression ( '..' constExpression )?
//  ;
private bool element(Source source) nothrow in {
    assert(source);
} body {
    if (!constantExpression(source)) return false;

    while (true) {
        source.bookmark();

        consumeWhitespace(source);
        if (!consumeLiteral(source, "..")) {
            source.rollback();
            break;
        }

        if (!constantExpression(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}
