module grammar.expression;

import compiler.source;
import compiler.util;
import grammar.lex;
import grammar.parameter;
import grammar.qualified;
import grammar.variable;

// 7 Expressions

//expression :
//  simple_expression ( relational_operator simple_expression )?
//  ;
// ***** PIM 4 Appendix 1 line 47 *****
//expression :
//  simpleExpression ( relation simpleExpression )?
//  ;
public bool expression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!simpleExpression(source)) return false;

    source.bookmark();
    if (relationalOperator(source)) {
        source.commit();
        return simpleExpression(source);
    } else {
        source.rollback();
    }

    return true;
}

//simple_expression :
//  ( '+' | '-' )? term ( term_operator term )*
//  ;
// ***** PIM 4 Appendix 1 line 48 *****
//simpleExpression :
//  ( '+' | '-' {})? term ( addOperator term )*
//  ;
private bool simpleExpression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (consumeSymbol(source, "+")) {
        source.commit();
    } else if (consumeSymbol(source, "-")) {
        source.commit();
    } else {
        source.rollback();
    }

    if (!term(source)) return false;

    while (true) {
        source.bookmark();

        if (!addOperator(source)) {
            source.rollback();
            break;
        }

        if (!term(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}

//term :
//  factor ( factor_operator factor )*
//  ;
// ***** PIM 4 Appendix 1 line 49 *****
//term :
//  factor ( mulOperator factor )*
//  ;
private bool term(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!factor(source)) return false;

    while (true) {
        source.bookmark();

        if (!mulOperator(source)) {
            source.rollback();
            break;
        }

        if (!factor(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}

//factor :
//  '(' expression ')' |
//  'NOT' factor |
//  value_designator |
//  function_call |
//  value_constructor |
//  constant_literal
//  ;
// ***** PIM 4 Appendix 1 lines 50-51 *****
// refactored for LL(1)
//
// Note: PIM 4 text says '~' is a synonym for 'NOT'
//       but the grammar does not actually show it
//factor :
//  number |
//  string |
//  setOrDesignatorOrProcCall |
//  '(' expression ')' | ( NOT | '~' {}) factor
//  ;
private bool factor(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (number(source)) return true;
    if (stringLiteral(source)) return true;

    if (consumeKeyword(source, "NOT") || consumeSymbol(source, "~")) {
        return factor(source);
    }

    source.bookmark();
    if (consumeSymbol(source, "(")) {
        if (expression(source)) {
            source.commit();
            return consumeSymbol(source, ")");
        } else {
            source.rollback();
        }
    } else {
        source.rollback();
    }

    return setOrDesignatorOrProcCall(source);
}

// ***** PIM 4 Appendix 1 lines 50-51 *****
// new for LL(1)
//setOrDesignatorOrProcCall :
//  set |
//  qualident /* <= factored out */
//  ( set | designatorTail? actualParameters? )
//;
private bool setOrDesignatorOrProcCall(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    //set |
    source.bookmark();
    if (set(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    //qualident
    if (!qualifiedIdentifier(source)) return false;

    // set |
    source.bookmark();
    if (set(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    //designatorTail?
    source.bookmark();
    if (designatorTail(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    //actualParameters?
    source.bookmark();
    if (actualParameters(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return true;
}

// ***** PIM 4 Appendix 1 line 46 *****
//expList :
//  expression ( ',' expression )*
//  ;
private bool expressionList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!expression(source)) return false;

    while (true) {
        source.bookmark();

        if (!consumeSymbol(source, ",")) {
            source.rollback();
            break;
        }

        if (!expression(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}

//ordinal_expression :
//  expression
//  ;
public bool ordinalExpression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return expression(source);
}

// 7.1 Infix Expressions

//relational_operator :
//  '=' | '#' | '<' | '<=' | '>' | '>=' | 'IN' |
//  ;
// ***** PIM 4 Appendix 1 line 14 *****
//relation :
//  '=' | '#' | '<>' | '<' | '<=' | '>' | '>=' | 'IN' {}
//  ;
private bool relationalOperator(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (consumeKeyword(source, "IN")) return true;

    if (consumeSymbol(source, "<>")) return true;
    if (consumeSymbol(source, "<=")) return true;
    if (consumeSymbol(source, ">=")) return true;

    if (consumeSymbol(source, "=")) return true;
    if (consumeSymbol(source, "#")) return true;
    if (consumeSymbol(source, "<")) return true;

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
private bool addOperator(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (consumeKeyword(source, "OR")) return true;

    if (consumeSymbol(source, "+")) return true;
    if (consumeSymbol(source, "-")) return true;

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
private bool mulOperator(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (consumeKeyword(source, "AND")) return true;
    if (consumeKeyword(source, "DIV")) return true;
    if (consumeKeyword(source, "MOD")) return true;
    if (consumeKeyword(source, "REM")) return true;

    if (consumeSymbol(source, "*")) return true;
    if (consumeSymbol(source, "/")) return true;

    return false;
}

// 7.2 Value Designator

//value_designator :
//  entire_value | indexed_value | selected_value | dereferenced_value
//  ;
// ***** PIM 4 Appendix 1 line 45 *****
// refactored for LL(1)
//designator :
//  qualident ( designatorTail )?
//  ;
public bool valueDesignator(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!qualifiedIdentifier(source)) return false;

    source.bookmark();
    if (designatorTail(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    return true;
}

// ***** PIM 4 Appendix 1 line 45 *****
// new for LL(1)
//designatorTail :
//  ( ( '[' expList ']' | '^' ) ( '.' ident )* )+
//  ;
private bool designatorTail(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    bool lambda() {
        source.bookmark();
        if (indexedValue(source)) {
            source.commit();
        } else {
            source.rollback();

            if (!dereferencedValue(source)) {
                return false;
            }
        }

        while (true) {
            source.bookmark();

            if (!selectedValue(source)) {
                source.rollback();
                break;
            }

            source.commit();
        }

        return true;
    }

    if (!lambda()) return false;

    while (true) {
        source.bookmark();

        if (!lambda()) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}

// 7.2.1 Entire Value

//entire_value :
//  qualified_identifier
//  ;
// ***** PIM 4 Appendix 1 line 45 *****
// new for LL(1)
//designatorTail :
//  ( ( '[' expList ']' | '^' ) ( '.' ident )* )+
//  ;

// 7.2.2 Indexed Value

//indexed_value :
//  array_value '[' index_expression ( ',' index_expression )* ']'
//  ;
// ***** PIM 4 Appendix 1 line 45 *****
// new for LL(1)
//designatorTail :
//  ( ( '[' expList ']' | '^' ) ( '.' ident )* )+
//  ;
private bool indexedValue(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!consumeSymbol(source, "[")) return false;

    if (!indexExpression(source)) return false;

    while (true) {
        source.bookmark();

        if (!consumeSymbol(source, ",")) {
            source.rollback();
            break;
        }

        if (!indexExpression(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return consumeSymbol(source, "]");
}

private bool indexExpression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return expression(source);
}

//array_value :
//  value_designator
//  ;

// 7.2.3 Selected Value

//selected_value :
//  record_value '.' field_identifier
//  ;
// ***** PIM 4 Appendix 1 line 45 *****
// new for LL(1)
//designatorTail :
//  ( ( '[' expList ']' | '^' ) ( '.' ident )* )+
//  ;
private bool selectedValue(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!consumeSymbol(source, ".")) return false;
    return fieldIdentifier(source);
}

//record_value :
//  value_designator
//  ;

// 7.2.4 Dereferenced Value

//dereferenced_value :
//  pointer_value '^'
//  ;
// ***** PIM 4 Appendix 1 line 45 *****
// new for LL(1)
//designatorTail :
//  ( ( '[' expList ']' | '^' ) ( '.' ident )* )+
//  ;
private bool dereferencedValue(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return consumeSymbol(source, "^");
}

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
public bool constantExpression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

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
private bool simpleConstExpression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!consumeSymbol(source, "+")) {
        consumeSymbol(source, "-");
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
private bool constTerm(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

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
private bool constFactor(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    // number
    if (wholeNumberLiteral(source)) return true;

    // string
    if (stringLiteral(source)) return true;

    // ( constExpression )
    source.bookmark();
    if (consumeSymbol(source, "(")) {
        if (constantExpression(source)) {
            if (consumeSymbol(source, ")")) {
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
    if (consumeKeyword(source, "NOT") || consumeSymbol(source, "~")) {
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
private bool setOrQualident(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

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
private bool set(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!consumeSymbol(source, "{")) return false;

    source.bookmark();
    if (element(source)) {
        while (true) {
            source.bookmark();

            if (!consumeSymbol(source, ",")) {
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

    return consumeSymbol(source, "}");
}

// ***** PIM 4 Appendix 1 line 22 *****
//element :
//  constExpression ( '..' constExpression )?
//  ;
private bool element(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!constantExpression(source)) return false;

    source.bookmark();
    if (consumeSymbol(source, "..")) {
        source.commit();
    } else {
        source.rollback();
        return true;
    }

    return constantExpression(source);
}
