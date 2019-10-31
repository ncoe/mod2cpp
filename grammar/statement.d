module grammar.statement;

import compiler.source;
import compiler.util;
import grammar.lex;

// 5 Statements

//statement :
//  empty_statement | assignment_statement | procedure_call |
//  return_statement | retry_statement | with_statement |
//  if_statement | case_statement | while_statement |
//  repeat_statement | loop_statement | exit_statement |
//  for_statement
//  ;
// ***** PIM 4 Appendix 1 lines 53-56 *****
// refactored for LL(1)
//statement :
//  ( assignmentOrProcCall | ifStatement | caseStatement |
//    whileStatement | repeatStatement | loopStatement | forStatement |
//   withStatement | EXIT | RETURN expression? )?
//  ;
private bool statement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    debugWrite(source, "End of Implementation");
    assert(false, "todo finish this");
}

// 5.1 Statement Sequence

//statement_sequence :
//  statement ( ';' statement )*
//  ;
// ***** PIM 4 Appendix 1 line 59 *****
//statementSequence :
//  statement ( ';' statement )*
//  ;
public bool statementSequence(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!statement(source)) return false;

    while (true) {
        source.bookmark();

        consumeWhitespace(source);
        if (!consumeLiteral(source, ";")) {
            source.rollback();
            break;
        }
        if (!statement(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}

// 5.2 Empty Statement

//empty_statement :
//  ';'
//  ;

// 5.3 Assigmment Statement

//assignment_statement :
//  variable_designator ':=' expression
//  ;

// 5.4 Procedure Call

//procedure_call :
//  procedure_designator ( actual_parameters )?
//  ;

//procedure_designator :
//  value_designator
//  ;

// 5.5 Return Statement

//return_statement :
//  simple_return_statement | function_return_statement
//  ;

// 5.5.1 Simple Return Statement

//simple_return_statement :
//  'RETURN'
//  ;

// 5.5.3 Function Return Statement

//function_return_statement :
//  'RETURN' expression
//  ;

// 5.6 Retry Statement

//retry_statement :
//  'RETRY'
//  ;

// 5.7 With Statement

//with_statement :
//  'WITH' record_designator 'DO' statement_sequence 'END'
//  ;

//record_designator :
//  variable_designator | value_designator
//  ;

// 5.8 If Statement

//if_statement :
//  guarded_statements ( if_else_part )? 'END'
//  ;

//guarded_statements :
//  'IF' boolean_expression 'THEN' statement_sequence
//  ( 'ELSIF' boolean_expression 'THEN' statement_sequence )*
//  ;

//if_else_part :
//  'ELSE' statement_sequence
//  ;

//boolean_expression :
//  expression
//  ;

// 5.9 Case Statement

//case_statement :
//  'CASE' case_selector 'OF' case_list 'END'
//  ;

//case_selector :
//  ordinal_expression
//  ;

//case_list :
//  case_alternative ( '|' case_alternative )*
//  ;

//case_else_part :
//  'ELSE' statement_sequence
//  ;

// 5.9.1 Case Alternative

//case_alternative :
//  ( case_label_list )? ':' statement_sequence
//  ;

//case_label_list :
//  case_label ( ',' case_label )*
//  ;

//case_label :
//  constant_expression ( '..' constant_expression )?
//  ;

// 5.10 While Statement

//while_statement :
//  'WHILE' boolean_expression 'DO' statement_sequence 'END'
//  ;

// 5.11 Repeat Statement

//repeat_statement :
//  'REPEAT' statement_sequence 'UNTIL' boolean_expression
//  ;

// 5.12 Loop Statement

//loop_statement :
//  'LOOP' statement_sequence 'END'
//  ;

// 5.13 Exit Statement

//exit_statement :
//  'EXIT'
//  ;

// 5.14 For Statement

//for_statement :
//  'FOR' control_variable_identifier ':=' initial_value 'TO' final_value
//  ( 'BY' step_size )? 'DO' statement_sequence 'END'
//  ;

//control_variable_identifier :
//  identifier
//  ;

//initial_value :
//  ordinal_expression
//  ;

//final_value :
//  ordinal_expression
//  ;

//step_size :
//  constant_expression
//  ;
