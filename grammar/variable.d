module grammar.variable;

// 6 Variable Designator

//variable_designator :
//  entire_designator | indexed_designator | selected_designator |
//  dereferenced_designator
//  ;

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

// 6.4 Dereferenced Designator

//dereferenced_designator :
//  pointer_variable_designator '^'
//  ;

//pointer_variable_designator :
//  variable_designator
//  ;
