module grammar.qualified;

import compiler.source;
import compiler.util;
import grammar.block;
import grammar.expression;
import grammar.lex;
import grammar.program;
import grammar.types;

// 2.1 Qualified Identifiers

//qualified_identifier :
//  ( module_identifier '.' )* identifier
//  ;
// ***** PIM 4 Appendix 1 line 11 *****
//qualident :
//  ident ( '.' ident )*
//  ;
public bool parseQualifiedIdentifier(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    while (true) {
        source.bookmark();

        if (!parseModuleIdentifier(source)) {
            source.rollback();
            break;
        }

        if (!lexSymbol(source, ".")) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return cast(bool) lexIdentifier(source);
}

// 2.2 Definitions

//definitions :
//  ( definition )*
//  ;

//definition :
//  'CONST' ( constant_declaration ';' )* |
//  'TYPE' ( type_declaration ';' )* |
//  'VAR' ( variable_declaration ';' )* |
//  procedure_heading ';'
//  ;

//procedure_heading :
//  proper_procedure_heading | function_procedure_heading
//  ;
// ***** PIM 4 Appendix 1 line 73 *****
//procedureHeading :
//  PROCEDURE ident formalParameters?
//  ;

// 2.2.1 Type Definitions

//type_definition :
//  type_declaration | opaque_type_definition
//  ;

//opaque_type_definition :
//  identifier
//  ;

// 2.2.2 Proper Procedure Heading

//proper_procedure_heading :
//  'PROCEDURE' procedure_identifier ( formal_parameters )? ';'
//  ;
// ***** PIM 4 Appendix 1 line 73 *****
//procedureHeading :
//  PROCEDURE ident formalParameters?
//  ;
private bool parseProperProcedureHeading(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "PROCEDURE")) return false;
    if (!parseProcedureIdentifier(source)) return false;

    source.bookmark();
    if (parseFormalParameters(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    return true;
}

//formal_parameters :
//  '(' ( formal_parameter_list )? ')'
//  ;
// ***** PIM 4 Appendix 1 lines 79-80 *****
//formalParameters :
//'(' ( fpSection ( ';' fpSection )* )? ')' ( ':' qualident )?
//;
private bool parseFormalParameters(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexSymbol(source, "(")) return false;

    source.bookmark();
    if (parseFormalParameterList(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    return lexSymbol(source, ")");
}

//formal_parameter_list :
//  formal_parameter ( ';' formal_parameter )*
//  ;
// ***** PIM 4 Appendix 1 lines 79-80 *****
//formalParameters :
//  '(' ( fpSection ( ';' fpSection )* )? ')' ( ':' qualident )?
//  ;
private bool parseFormalParameterList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseFormalParameter(source)) return false;

    while (true) {
        source.bookmark();

        if (!lexSymbol(source, ";")) {
            source.rollback();
            break;
        }

        if (!parseFormalParameter(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}

// 2.2.3 Function Procedure Heading

//function_procedure_heading :
//  'PROCEDURE' procedure_identifier ( formal_parameters )?
//  ':' function_result_type ';'
//  ;
// ***** PIM 4 Appendix 1 line 73 *****
//procedureHeading :
//  PROCEDURE ident formalParameters?
//  ;
// ***** PIM 4 Appendix 1 lines 79-80 *****
//formalParameters :
//'(' ( fpSection ( ';' fpSection )* )? ')' ( ':' qualident )?
//;
private bool parseFunctionProcedureHeading(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "PROCEDURE")) return false;
    if (!parseProcedureIdentifier(source)) return false;

    source.bookmark();
    if (parseFormalParameters(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    if (!lexSymbol(source, ":")) return false;
    return parseFunctionResultType(source);
}

//function_result_type :
//  type_identifier;
// ***** PIM 4 Appendix 1 lines 79-80 *****
//formalParameters :
//'(' ( fpSection ( ';' fpSection )* )? ')' ( ':' qualident )?
//;
public bool parseFunctionResultType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseTypeIdentifier(source);
}

// 2.2.4 Formal Parameter

//formal_parameter :
//  value_parameter_specification | variable_parameter_specification
//  ;
// ***** PIM 4 Appendix 1 line 81 *****
//fpSection :
//  VAR? identList ':' formalType
//  ;
private bool parseFormalParameter(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (parseVariableParameterSpecification(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (parseValueParameterSpecification(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return false;
}

// 2.2.4.1 Value Parameter

//value_parameter_specification :
//  identifier_list ':' formal_type
//  ;
// ***** PIM 4 Appendix 1 line 81 *****
//fpSection :
//  VAR? identList ':' formalType
//  ;
private bool parseValueParameterSpecification(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseIdentifierList(source)) return false;
    if (!lexSymbol(source, ":")) return false;
    return parseFormalType(source);
}

// 2.2.4.2 Variable Parameter

//variable_parameter_specification :
//  'VAR' identifier_list ':' formal_type
//  ;
// ***** PIM 4 Appendix 1 line 81 *****
//fpSection :
//  VAR? identList ':' formalType
//  ;
private bool parseVariableParameterSpecification(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "VAR")) return false;
    if (!parseIdentifierList(source)) return false;
    if (!lexSymbol(source, ":")) return false;
    return parseFormalType(source);
}

// 2.3 Declarations

//declarations :
//  ( declaration )*
//  ;
public bool parseDeclarations(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    while (true) {
        source.bookmark();

        if (parseDeclaration(source)) {
            source.commit();
        } else {
            source.rollback();
            break;
        }
    }

    return true;
}

//declaration :
//  'CONST' ( constant_declaration ';' )* |
//  'TYPE' ( type_declaration ';' )* |
//  'VAR' ( variable_declaration ';' )* |
//  procedure_declaration ';' |
//  local_module_declaration ';'	
//  ;
// ***** PIM 4 Appendix 1 lines 75-78 *****
//declaration :
//  CONST ( constantDeclaration ';' )* |
//  TYPE ( typeDeclaration ';' )* |
//  VAR ( variableDeclaration ';' )* |
//  procedureDeclaration ';' |
//  moduleDeclaration ';'
//  ;
private bool parseDeclaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (lexKeyword(source, "CONST")) {
        source.commit();

        while (true) {
            source.bookmark();

            if (!parseConstantDeclaration(source)) {
                source.rollback();
                break;
            }

            if (!lexSymbol(source, ";")) {
                source.rollback();
                break;
            }

            source.commit();
        }

        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (lexKeyword(source, "TYPE")) {
        source.commit();

        while (true) {
            source.bookmark();

            if (!parseTypeDeclaration(source)) {
                source.rollback();
                break;
            }

            if (!lexSymbol(source, ";")) {
                source.rollback();
                break;
            }

            source.commit();
        }

        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (lexKeyword(source, "VAR")) {
        source.commit();

        while (true) {
            source.bookmark();

            if (!parseVariableDeclaration(source)) {
                source.rollback();
                break;
            }

            if (!lexSymbol(source, ";")) {
                source.rollback();
                break;
            }

            source.commit();
        }

        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (parseProcedureDeclaration(source)) {
        if (lexSymbol(source, ";")) {
            source.commit();
            return true;
        } else {
            source.rollback();
            return false;
        }
    } else {
        source.rollback();
    }

    return parseLocalModuleDeclaration(source);
}

// 2.4 Constant Declaration

//constant_declaration :
//  identifier '=' constant_expression
//  ;
// ***** PIM 4 Appendix 1 line 12 *****
//constantDeclaration :	
//  ident '=' constExpression
//  ;
private bool parseConstantDeclaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexIdentifier(source)) return false;
    if (!lexSymbol(source, "=")) return false;
    return parseConstantExpression(source);
}

// 2.5 Type Declaration

//type_declaration :
//  identifier '=' type_denoter
//  ;
private bool parseTypeDeclaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    debugWrite(source, "End of Implementation");
    assert(false, "todo finish this");
}

// 2.6 Variable Declaration

//variable_declaration :
//  variable_identifier_list ':' type_denoter
//  ;
// ***** PIM 4 Appendix 1 line 44 *****
//variableDeclaration :
//  identList ':' type
//  ;
private bool parseVariableDeclaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseVariableIdentifierList(source)) return false;
    if (!lexSymbol(source, ":")) return false;
    return parseTypeDenoter(source);
}

//variable_identifier_list :
//  identifier ( machine_address )? ( ',' identifier ( machine_address )? )*
//  ;
private bool parseVariableIdentifierList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    bool lambda() {
        if (!lexIdentifier(source)) return false;

        source.bookmark();
        if (parseMachineAddress(source)) {
            source.commit();
        } else {
            source.rollback();
        }

        return true;
    }

    if (!lambda()) return false;

    while (true) {
        source.bookmark();

        if (!lexSymbol(source, ",")) {
            source.rollback();
            break;
        }

        if (!lambda()) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}

//machine_address :
//  '[' value_of_address_type ']'
//  ;
private bool parseMachineAddress(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexSymbol(source, "[")) return false;
    if (!parseValueOfAddressType(source)) return false;
    return lexSymbol(source, "]");
}

//value_of_address_type :
//  constant_expression
//  ;
private bool parseValueOfAddressType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseConstantExpression(source);
}

// 2.7 Procedure Declaration

//procedure_declaration :
//  proper_procedure_declaration | function_procedure_declaration
//  ;
// ***** PIM 4 Appendix 1 line 72 *****
//procedureDeclaration :
//  procedureHeading ';' block ident
//  ;
private bool parseProcedureDeclaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (parseFunctionProcedureDeclaration(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (parseProperProcedureDeclaration(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return false;
}

// 2.8 Proper Procedure Declaration

//proper_procedure_declaration :
//  proper_procedure_heading ';'
//  ( proper_procedure_block procedure_identifier | 'FORWARD' )
//  ;
private bool parseProperProcedureDeclaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseProperProcedureHeading(source)) return false;
    if (!lexSymbol(source, ";")) return false;

    source.bookmark();
    if (lexKeyword(source, "FORWARD")) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    if (!parseProperProcedureBlock(source)) return false;
    return parseProcedureIdentifier(source);
}

//procedure_identifier :
//  identifier
//  ;
private bool parseProcedureIdentifier(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return cast(bool) lexIdentifier(source);
}

// 2.8.1 Function Procedure Declaration

//function_procedure_declaration :
//  function_procedure_heading ';'
//  ( function_procedure_block procedure_identifier | 'FORWARD' )
//  ;
private bool parseFunctionProcedureDeclaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseFunctionProcedureHeading(source)) return false;
    if (!lexSymbol(source, ";")) return false;

    source.bookmark();
    if (lexKeyword(source, "FORWARD")) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    if (!parseFunctionProcedureBlock(source)) return false;
    return parseProcedureIdentifier(source);
}

// 2.9 Local Module Declaration

//local_module_declaration :
//  'MODULE' module_identifier ( protection )? ';'
//  import_lists ( export_list )? module_block module_identifier 
//  ;
// ***** PIM 4 Appendix 1 lines 83-84 *****
//moduleDeclaration :
//  MODULE ident priority? ';'
//  importList* exportList?
//  block ident
//  ;
private bool parseLocalModuleDeclaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "MODULE")) return false;
    if (!parseModuleIdentifier(source)) return false;

    source.bookmark();
    if (parseProtection(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    if (!lexSymbol(source, ";")) return false;
    if (!parseImportLists(source)) return false;

    source.bookmark();
    if (parseExportList(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    if (!parseModuleBlock(source)) return false;
    return parseModuleIdentifier(source);
}
