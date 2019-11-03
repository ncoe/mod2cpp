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
public bool parseExpression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseSimpleExpression(source)) return false;

    source.bookmark();
    if (parseRelationalOperator(source)) {
        source.commit();
        return parseSimpleExpression(source);
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
private bool parseSimpleExpression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (lexSymbol(source, "+") || lexSymbol(source, "-")) {
        source.commit();
    } else {
        source.rollback();
    }

    if (!parseTerm(source)) return false;

    while (true) {
        source.bookmark();

        if (!parseAddOperator(source)) {
            source.rollback();
            break;
        }

        if (!parseTerm(source)) {
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
private bool parseTerm(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseFactor(source)) return false;

    while (true) {
        source.bookmark();

        if (!parseMulOperator(source)) {
            source.rollback();
            break;
        }

        if (!parseFactor(source)) {
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
private bool parseFactor(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (lexNumberLiteral(source)) return true;
    if (lexStringLiteral(source)) return true;

    if (lexKeyword(source, "NOT") || lexSymbol(source, "~")) {
        return parseFactor(source);
    }

    source.bookmark();
    if (lexSymbol(source, "(")) {
        if (parseExpression(source)) {
            source.commit();
            return lexSymbol(source, ")");
        } else {
            source.rollback();
        }
    } else {
        source.rollback();
    }

    return parseSetOrDesignatorOrProcCall(source);
}

// ***** PIM 4 Appendix 1 lines 50-51 *****
// new for LL(1)
//setOrDesignatorOrProcCall :
//  set |
//  qualident /* <= factored out */
//  ( set | designatorTail? actualParameters? )
//;
private bool parseSetOrDesignatorOrProcCall(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    //set |
    source.bookmark();
    if (parseSet(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    //qualident
    if (!parseQualifiedIdentifier(source)) return false;

    // set |
    source.bookmark();
    if (parseSet(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    //designatorTail?
    source.bookmark();
    if (parseDesignatorTail(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    //actualParameters?
    source.bookmark();
    if (parseActualParameters(source)) {
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
private bool parseExpressionList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseExpression(source)) return false;

    while (true) {
        source.bookmark();

        if (!lexSymbol(source, ",")) {
            source.rollback();
            break;
        }

        if (!parseExpression(source)) {
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
public bool parseOrdinalExpression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseExpression(source);
}

// 7.1 Infix Expressions

//relational_operator :
//  '=' | '#' | '<' | '<=' | '>' | '>=' | 'IN' |
//  ;
// ***** PIM 4 Appendix 1 line 14 *****
//relation :
//  '=' | '#' | '<>' | '<' | '<=' | '>' | '>=' | 'IN' {}
//  ;
private bool parseRelationalOperator(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (lexKeyword(source, "IN")) return true;

    if (lexSymbol(source, "<>")) return true;
    if (lexSymbol(source, "<=")) return true;
    if (lexSymbol(source, ">=")) return true;

    if (lexSymbol(source, "=")) return true;
    if (lexSymbol(source, "#")) return true;
    if (lexSymbol(source, "<")) return true;

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
private bool parseAddOperator(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (lexKeyword(source, "OR")) return true;

    if (lexSymbol(source, "+")) return true;
    if (lexSymbol(source, "-")) return true;

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
private bool parseMulOperator(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (lexKeyword(source, "AND")) return true;
    if (lexKeyword(source, "DIV")) return true;
    if (lexKeyword(source, "MOD")) return true;
    if (lexKeyword(source, "REM")) return true;

    if (lexSymbol(source, "*")) return true;
    if (lexSymbol(source, "/")) return true;

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
public bool parseValueDesignator(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseQualifiedIdentifier(source)) return false;

    source.bookmark();
    if (parseDesignatorTail(source)) {
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
private bool parseDesignatorTail(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    bool lambda() {
        source.bookmark();
        if (parseIndexedValue(source)) {
            source.commit();
        } else {
            source.rollback();

            if (!parseDereferencedValue(source)) {
                return false;
            }
        }

        while (true) {
            source.bookmark();

            if (!parseSelectedValue(source)) {
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
private bool parseIndexedValue(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexSymbol(source, "[")) return false;

    if (!parseIndexExpression(source)) return false;

    while (true) {
        source.bookmark();

        if (!lexSymbol(source, ",")) {
            source.rollback();
            break;
        }

        if (!parseIndexExpression(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return lexSymbol(source, "]");
}

private bool parseIndexExpression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseExpression(source);
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
private bool parseSelectedValue(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexSymbol(source, ".")) return false;
    return parseFieldIdentifier(source);
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
private bool parseDereferencedValue(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return lexSymbol(source, "^");
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
public bool parseConstantExpression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseSimpleConstExpression(source)) return false;

    while (true) {
        source.bookmark();

        if (!parseRelationalOperator(source)) {
            source.rollback();
            break;
        }

        if (!parseSimpleConstExpression(source)) {
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
private bool parseSimpleConstExpression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexSymbol(source, "+")) {
        lexSymbol(source, "-");
    }

    if (!parseConstTerm(source)) return false;

    while (true) {
        source.bookmark();

        if (!parseAddOperator(source)) {
            source.rollback();
            break;
        }

        if (!parseConstTerm(source)) {
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
private bool parseConstTerm(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseConstFactor(source)) return false;

    while (true) {
        source.bookmark();

        if (!parseMulOperator(source)) {
            source.rollback();
            break;
        }

        if (!parseConstFactor(source)) {
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
private bool parseConstFactor(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    // number
    if (lexNumberLiteral(source)) return true;

    // string
    if (lexStringLiteral(source)) return true;

    // ( constExpression )
    source.bookmark();
    if (lexSymbol(source, "(")) {
        if (parseConstantExpression(source)) {
            if (lexSymbol(source, ")")) {
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
    if (lexKeyword(source, "NOT") || lexSymbol(source, "~")) {
        source.commit();
        return parseConstFactor(source);
    } else {
        source.rollback();
    }

    // setOrQualident
    return parseSetOrQualident(source);
}

// ***** PIM 4 Appendix 1 lines 19-20 *****
// new for LL(1)
//setOrQualident :
//  set | qualident set?
//  ;
private bool parseSetOrQualident(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    // qualident set?
    source.bookmark();
    if (parseQualifiedIdentifier(source)) {
        source.bookmark();
        if (parseSet(source)) {
            source.commit();
        } else {
            source.rollback();
        }

        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return parseSet(source);
}

// ***** PIM 4 Appendix 1 line 21 *****
// refactored for LL(1)
//set :
//  /* qualident has been factored out */
//  '{' ( element ( ',' element )* )? '}'
//  ;
private bool parseSet(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexSymbol(source, "{")) return false;

    source.bookmark();
    if (parseElement(source)) {
        while (true) {
            source.bookmark();

            if (!lexSymbol(source, ",")) {
                source.rollback();
                break;
            }

            if (!parseElement(source)) {
                source.rollback();
                break;
            }

            source.commit();
        }

        source.commit();
    } else {
        source.rollback();
    }

    return lexSymbol(source, "}");
}

// ***** PIM 4 Appendix 1 line 22 *****
//element :
//  constExpression ( '..' constExpression )?
//  ;
private bool parseElement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseConstantExpression(source)) return false;

    source.bookmark();
    if (lexSymbol(source, "..")) {
        source.commit();
    } else {
        source.rollback();
        return true;
    }

    return parseConstantExpression(source);
}
