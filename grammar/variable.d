module grammar.variable;

import compiler.source;
import compiler.util;
import grammar.lex;
import grammar.qualified;

// 6 Variable Designator

//variable_designator :
//  entire_designator | indexed_designator | selected_designator |
//  dereferenced_designator
//  ;
public bool variableDesignator(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    debugWrite(source, "End of Implementation");
    assert(false, "todo finish this");
}

// 6.1 Entire Designator

//entire_designator :
//  qualified_identifier
//  ;

// 6.2 Indexed Designator

//indexed_designator :
//  array_variable_designator '[' index_expression ( ',' index_expression )* ']'
//  ;

//array_variable_designator :
//  variable_designator
//  ;

//index_expression :
//  ordinal_expression
//  ;

// 6.3 Selected Designator

//selected_designator :
//  record_variable_designator '.' field_identifier
//  ;

//record_variable_designator :
//  variable_designator;

//field_identifier :
//  identifier
//  ;
public bool fieldIdentifier(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return cast(bool) identifier(source);
}

// 6.4 Dereferenced Designator

//dereferenced_designator :
//  pointer_variable_designator '^'
//  ;

//pointer_variable_designator :
//  variable_designator
//  ;
