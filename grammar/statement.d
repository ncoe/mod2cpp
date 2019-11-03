module grammar.statement;

import compiler.source;
import compiler.util;
import grammar.expression;
import grammar.lex;
import grammar.parameter;

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

    // (';') empty_statement
    source.bookmark();
    if (emptyStatement(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    // ('EXIT') exit_statement
    source.bookmark();
    if (exitStatement(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    // ('RETRY') retry_statement
    source.bookmark();
    if (retryStatement(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    // ('RETURN') return_statement
    source.bookmark();
    if (returnStatement(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    // ('WITH') with_statement
    source.bookmark();
    if (withStatement(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    // ('IF') if_statement
    source.bookmark();
    if (ifStatement(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    // ('CASE') case_statement
    source.bookmark();
    if (caseStatement(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    // ('WHILE') while_statement
    source.bookmark();
    if (whileStatement(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    // ('REPEAT') repeat_statement
    source.bookmark();
    if (repeatStatement(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    // ('LOOP') loop_statement
    source.bookmark();
    if (loopStatement(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    // ('FOR') for_statement
    source.bookmark();
    if (forStatement(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    // (variable_designator ':=' expression) assignment_statement
    // (procedure_designator ( actual_parameters )?) procedure_call
    return assignmentOrProcedureCall(source);
}

// ***** PIM 4 Appendix 1 line 57 *****
// ***** PIM 4 Appendix 1 line 58 *****
// new for LL(1)
//assignmentOrProcCall :
//  designator /* has been factored out */
//  ( ':=' expression | actualParameters? )
//  ;
private bool assignmentOrProcedureCall(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!valueDesignator(source)) return false;

    source.bookmark();
    if (assignmentStatement(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    source.bookmark();
    if (actualParameters(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    return true;
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

        if (!lexSymbol(source, ";")) {
            source.rollback();
            break;
        }
        if (!statement(source)) {
            //NOTE: the empty statement does not handle the case where the last part of the sequence is the semicolon.
            //source.rollback();
            source.commit();
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
private bool emptyStatement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return lexSymbol(source, ";");
}

// 5.3 Assigmment Statement

//assignment_statement :
//  variable_designator ':=' expression
//  ;
// ***** PIM 4 Appendix 1 line 57 *****
// new for LL(1)
//assignmentOrProcCall :
//  designator /* has been factored out */
//  ( ':=' expression | actualParameters? )
//  ;
private bool assignmentStatement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    /* designator already handled */

    if (!lexSymbol(source, ":=")) return false;
    return expression(source);
}

// 5.4 Procedure Call

//procedure_call :
//  procedure_designator ( actual_parameters )?
//  ;
// ***** PIM 4 Appendix 1 line 58 *****
// new for LL(1)
//assignmentOrProcCall :
//  designator /* has been factored out */
//  ( ':=' expression | actualParameters? )
//  ;
private bool procedureCall(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    /* designator already handled */

    source.bookmark();
    if (actualParameters(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    return true;
}

//procedure_designator :
//  value_designator
//  ;

// 5.5 Return Statement

//return_statement :
//  simple_return_statement | function_return_statement
//  ;
private bool returnStatement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (functionReturnStatement(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return simpleReturnStatement(source);
}

// 5.5.1 Simple Return Statement

//simple_return_statement :
//  'RETURN'
//  ;
private bool simpleReturnStatement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return lexKeyword(source, "RETURN");
}

// 5.5.3 Function Return Statement

//function_return_statement :
//  'RETURN' expression
//  ;
private bool functionReturnStatement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "RETURN")) return false;
    return expression(source);
}

// 5.6 Retry Statement

//retry_statement :
//  'RETRY'
//  ;
private bool retryStatement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return lexKeyword(source, "RETRY");
}

// 5.7 With Statement

//with_statement :
//  'WITH' record_designator 'DO' statement_sequence 'END'
//  ;
private bool withStatement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "WITH")) return false;

    debugWrite(source, "End of Implementation");
    assert(false, "todo finish this");
}

//record_designator :
//  variable_designator | value_designator
//  ;

// 5.8 If Statement

//if_statement :
//  guarded_statements ( if_else_part )? 'END'
//  ;
// ***** PIM 4 Appendix 1 lines 60-62 *****
//ifStatement :
//  IF expression THEN statementSequence
//  ( ELSIF expression THEN statementSequence )*
//  ( ELSE statementSequence )?
//  END
//  ;
private bool ifStatement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!guardedStatements(source)) return false;

    source.bookmark();
    if (ifElsePart(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    return lexKeyword(source, "END");
}

//guarded_statements :
//  'IF' boolean_expression 'THEN' statement_sequence
//  ( 'ELSIF' boolean_expression 'THEN' statement_sequence )*
//  ;
// ***** PIM 4 Appendix 1 lines 60-62 *****
//ifStatement :
//  IF expression THEN statementSequence
//  ( ELSIF expression THEN statementSequence )*
//  ( ELSE statementSequence )?
//  END
//  ;
private bool guardedStatements(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "IF")) return false;
    if (!booleanExpression(source)) return false;
    if (!lexKeyword(source, "THEN")) return false;
    if (!statementSequence(source)) return false;

    while (true) {
        source.bookmark();

        if (!lexKeyword(source, "ELSIF")) {
            source.rollback();
            break;
        }
        if (!booleanExpression(source)) {
            source.rollback();
            break;
        }
        if (!lexKeyword(source, "THEN")) {
            source.rollback();
            break;
        }
        if (!statementSequence(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}

//if_else_part :
//  'ELSE' statement_sequence
//  ;
private bool ifElsePart(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "ELSE")) return false;
    return statementSequence(source);
}

//boolean_expression :
//  expression
//  ;
private bool booleanExpression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return expression(source);
}

// 5.9 Case Statement

//case_statement :
//  'CASE' case_selector 'OF' case_list 'END'
//  ;
private bool caseStatement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "CASE")) return false;

    debugWrite(source, "End of Implementation");
    assert(false, "todo finish this");
}

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
private bool whileStatement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "WHILE")) return false;

    debugWrite(source, "End of Implementation");
    assert(false, "todo finish this");
}

// 5.11 Repeat Statement

//repeat_statement :
//  'REPEAT' statement_sequence 'UNTIL' boolean_expression
//  ;
private bool repeatStatement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "REPEAT")) return false;

    debugWrite(source, "End of Implementation");
    assert(false, "todo finish this");
}

// 5.12 Loop Statement

//loop_statement :
//  'LOOP' statement_sequence 'END'
//  ;
private bool loopStatement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "LOOP")) return false;

    debugWrite(source, "End of Implementation");
    assert(false, "todo finish this");
}

// 5.13 Exit Statement

//exit_statement :
//  'EXIT'
//  ;
private bool exitStatement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return lexKeyword(source, "EXIT");
}

// 5.14 For Statement

//for_statement :
//  'FOR' control_variable_identifier ':=' initial_value 'TO' final_value
//  ( 'BY' step_size )? 'DO' statement_sequence 'END'
//  ;
// ***** PIM 4 Appendix 1 lines 68-69 *****
//forStatement :
//  FOR ident ':=' expression TO expression ( BY constExpression )?
//  DO statementSequence END
//  ;
private bool forStatement(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "FOR")) return false;
    if (!controlVariableIdentifier(source)) return false;
    if (!lexSymbol(source, ":=")) return false;
    if (!initialValue(source)) return false;
    if (!lexKeyword(source, "TO")) return false;
    if (!finalValue(source)) return false;

    source.bookmark();
    if (lexKeyword(source, "BY")) {
        source.commit();
        if (!stepSize(source)) return false;
    } else {
        source.rollback();
    }

    if (!lexKeyword(source, "DO")) return false;
    if (!statementSequence(source)) return false;
    return lexKeyword(source, "END");
}

//control_variable_identifier :
//  identifier
//  ;
private bool controlVariableIdentifier(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return cast(bool) lexIdentifier(source);
}

//initial_value :
//  ordinal_expression
//  ;
private bool initialValue(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return ordinalExpression(source);
}

//final_value :
//  ordinal_expression
//  ;
private bool finalValue(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return ordinalExpression(source);
}

//step_size :
//  constant_expression
//  ;
private bool stepSize(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return constantExpression(source);
}
