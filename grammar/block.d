module grammar.block;

import compiler.source;
import compiler.util;
import grammar.lex;
import grammar.qualified;
import grammar.statement;

// 4 Blocks

// 4.1 Proper Procedure Block

//proper_procedure_block :
//  declarations ( procedure_body )? 'END'
//  ;
// ***** PIM 4 Appendix 1 line 74 *****
//block :
//  declaration*
//  ( BEGIN statementSequence )? END
//  ;
public bool properProcedureBlock(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!declarations(source)) return false;

    source.bookmark();
    if (procedureBody(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    consumeWhitespace(source);
    return consumeLiteral(source, "END");
}

//procedure_body :
//  'BEGIN' block_body
//  ;
private bool procedureBody(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "BEGIN")) return false;

    return blockBody(source);
}

// 4.2 Function Procedure Block

//function_procedure_block :
//  declarations function_body 'END'
//  ;
// ***** PIM 4 Appendix 1 line 74 *****
//block :
//  declaration*
//  ( BEGIN statementSequence )? END
//  ;
public bool functionProcedureBlock(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!declarations(source)) return false;

    if (!functionBody(source)) return false;

    consumeWhitespace(source);
    return consumeLiteral(source, "END");
}

//function_body :
//  'BEGIN' block_body
//  ;
private bool functionBody(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "BEGIN")) return false;

    return blockBody(source);
}

// 4.3 Module Block

//module_block :
//  declarations ( module_body )? 'END'
//  ;
// ***** PIM 4 Appendix 1 line 74 *****
//block :
//  declaration*
//  ( BEGIN statementSequence )? END
//  ;
public bool moduleBlock(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!declarations(source)) return false;

    source.bookmark();
    if (moduleBody(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    consumeWhitespace(source);
    if (!consumeLiteral(source, "END")) return false;

    return true;
}

//module_body :
//  initialization_body ( finalization_body )?
//  ;
// ***** PIM 4 Appendix 1 line 74 *****
//block :
//  declaration*
//  ( BEGIN statementSequence )? END
//  ;
private bool moduleBody(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!initializationBody(source)) return false;

    source.bookmark();
    if (finalizationBody(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    return true;
}

//initialization_body :
//  'BEGIN' block_body
//  ;
// ***** PIM 4 Appendix 1 line 74 *****
//block :
//  declaration*
//  ( BEGIN statementSequence )? END
//  ;
private bool initializationBody(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "BEGIN")) return false;

    if (!blockBody(source)) return false;

    return true;
}

//finalization_body :
//  'FINALLY' block_body
//  ;
private bool finalizationBody(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "FINALLY")) return false;

    if (!blockBody(source)) return false;

    return true;
}

// 4.4 Block Bodies and Exception Handling

//block_body :
//  normal_part ( 'EXCEPT' exceptional_part )?
//  ;
private bool blockBody(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!normalPart(source)) return false;

    source.bookmark();
    consumeWhitespace(source);
    if (consumeLiteral(source, "EXCEPT")) {
        if (exceptionalPart(source)) {
            source.commit();
        } else {
            source.rollback();
        }
    } else {
        source.rollback();
    }

    return true;
}

//normal_part :
//  statement_sequence
//  ;
private bool normalPart(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return statementSequence(source);
}

//exceptional_part :
//  statement_sequence
//  ;
private bool exceptionalPart(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return statementSequence(source);
}
