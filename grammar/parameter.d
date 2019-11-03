module grammar.parameter;

import compiler.source;
import compiler.util;
import grammar.expression;
import grammar.lex;

// 8 Parameter and Argument Binding

// 8.1 Actual Parameters

//actual_parameters :
//  '(' ( actual_parameter_list )? ')'
//  ;
// ***** PIM 4 Appendix 1 line 52 *****
//actualParameters :
//  '(' expList? ')'
//  ;
public bool actualParameters(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexSymbol(source, "(")) return false;

    source.bookmark();
    if (actualParameterList(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    return lexSymbol(source, ")");
}

//actual_parameter_list :
//  actual_parameter ( ',' actual_parameter )*
//  ;
// ***** PIM 4 Appendix 1 line 46 *****
//expList :
//  expression ( ',' expression )*
//  ;
private bool actualParameterList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!expression(source)) return false;

    while (true) {
        source.bookmark();

        if (!lexSymbol(source, ",")) {
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

//actual_parameter :
//  variable_designator | expression | type_parameter
//  ;

// 8.2 Special Parameters

// 8.2.1 Type Parameter

//type_parameter :
//  type_identifier
//  ;
