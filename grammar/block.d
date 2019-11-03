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
public bool parseProperProcedureBlock(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseDeclarations(source)) return false;

    source.bookmark();
    if (parseProcedureBody(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    return lexKeyword(source, "END");
}

//procedure_body :
//  'BEGIN' block_body
//  ;
private bool parseProcedureBody(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "BEGIN")) return false;
    return parseBlockBody(source);
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
public bool parseFunctionProcedureBlock(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseDeclarations(source)) return false;
    if (!parseFunctionBody(source)) return false;
    return lexKeyword(source, "END");
}

//function_body :
//  'BEGIN' block_body
//  ;
private bool parseFunctionBody(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "BEGIN")) return false;
    return parseBlockBody(source);
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
public bool parseModuleBlock(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseDeclarations(source)) return false;

    source.bookmark();
    if (parseModuleBody(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    return lexKeyword(source, "END");
}

//module_body :
//  initialization_body ( finalization_body )?
//  ;
// ***** PIM 4 Appendix 1 line 74 *****
//block :
//  declaration*
//  ( BEGIN statementSequence )? END
//  ;
private bool parseModuleBody(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseInitializationBody(source)) return false;

    source.bookmark();
    if (parseFinalizationBody(source)) {
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
private bool parseInitializationBody(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "BEGIN")) return false;
    return parseBlockBody(source);
}

//finalization_body :
//  'FINALLY' block_body
//  ;
private bool parseFinalizationBody(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "FINALLY")) return false;
    return parseBlockBody(source);
}

// 4.4 Block Bodies and Exception Handling

//block_body :
//  normal_part ( 'EXCEPT' exceptional_part )?
//  ;
private bool parseBlockBody(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseNormalPart(source)) return false;

    source.bookmark();
    if (lexKeyword(source, "EXCEPT")) {
        if (parseExceptionalPart(source)) {
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
private bool parseNormalPart(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseStatementSequence(source);
}

//exceptional_part :
//  statement_sequence
//  ;
private bool parseExceptionalPart(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseStatementSequence(source);
}
