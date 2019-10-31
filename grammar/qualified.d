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
public bool qualifiedIdentifier(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    while (true) {
        source.bookmark();

        consumeWhitespace(source);
        if (!moduleIdentifier(source)) {
            source.rollback();
            break;
        }

        consumeWhitespace(source);
        if (!consumeLiteral(source, ".")) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return identifier(source);
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
private bool properProcedureHeading(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "PROCEDURE")) return false;

    if (!consumeWhitespace(source)) return false;
    if (!procedureIdentifier(source)) return false;

    source.bookmark();
    if (formalParameters(source)) {
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
private bool formalParameters(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "(")) return false;

    source.bookmark();
    if (formalParameterList(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    return consumeLiteral(source, ")");
}

//formal_parameter_list :
//  formal_parameter ( ';' formal_parameter )*
//  ;
// ***** PIM 4 Appendix 1 lines 79-80 *****
//formalParameters :
//  '(' ( fpSection ( ';' fpSection )* )? ')' ( ':' qualident )?
//  ;
private bool formalParameterList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!formalParameter(source)) return false;

    while (true) {
        source.bookmark();

        consumeWhitespace(source);
        if (!consumeLiteral(source, ";")) {
            source.rollback();
            break;
        }

        if (!formalParameter(source)) {
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
private bool functionProcedureHeading(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "PROCEDURE")) return false;

    if (!consumeWhitespace(source)) return false;
    if (!procedureIdentifier(source)) return false;

    source.bookmark();
    if (formalParameters(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    consumeWhitespace(source);
    if (!consumeLiteral(source, ":")) return false;

    consumeWhitespace(source);
    return functionResultType(source);
}

//function_result_type :
//  type_identifier;
// ***** PIM 4 Appendix 1 lines 79-80 *****
//formalParameters :
//'(' ( fpSection ( ';' fpSection )* )? ')' ( ':' qualident )?
//;
public bool functionResultType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return typeIdentifier(source);
}

// 2.2.4 Formal Parameter

//formal_parameter :
//  value_parameter_specification | variable_parameter_specification
//  ;
// ***** PIM 4 Appendix 1 line 81 *****
//fpSection :
//  VAR? identList ':' formalType
//  ;
private bool formalParameter(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (variableParameterSpecification(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (valueParameterSpecification(source)) {
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
private bool valueParameterSpecification(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!identifierList(source)) return false;

    consumeWhitespace(source);
    if (!consumeLiteral(source, ":")) return false;

    consumeWhitespace(source);
    return formalType(source);
}

// 2.2.4.2 Variable Parameter

//variable_parameter_specification :
//  'VAR' identifier_list ':' formal_type
//  ;
// ***** PIM 4 Appendix 1 line 81 *****
//fpSection :
//  VAR? identList ':' formalType
//  ;
private bool variableParameterSpecification(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "VAR")) return false;

    if (!consumeWhitespace(source)) return false;
    if (!identifierList(source)) return false;

    consumeWhitespace(source);
    if (!consumeLiteral(source, ":")) return false;

    consumeWhitespace(source);
    return formalType(source);
}

// 2.3 Declarations

//declarations :
//  ( declaration )*
//  ;
public bool declarations(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    while (true) {
        source.bookmark();

        if (declaration(source)) {
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
private bool declaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);

    source.bookmark();
    if (consumeLiteral(source, "CONST")) {
        source.commit();

        while (true) {
            source.bookmark();

            if (!constantDeclaration(source)) {
                source.rollback();
                break;
            }

            consumeWhitespace(source);
            if (!consumeLiteral(source, ";")) {
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
    if (consumeLiteral(source, "TYPE")) {
        source.commit();

        while (true) {
            source.bookmark();

            if (!typeDeclaration(source)) {
                source.rollback();
                break;
            }

            consumeWhitespace(source);
            if (!consumeLiteral(source, ";")) {
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
    if (consumeLiteral(source, "VAR")) {
        source.commit();

        while (true) {
            source.bookmark();

            if (!variableDeclaration(source)) {
                source.rollback();
                break;
            }

            consumeWhitespace(source);
            if (!consumeLiteral(source, ";")) {
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
    if (procedureDeclaration(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return localModuleDeclaration(source);
}

// 2.4 Constant Declaration

//constant_declaration :
//  identifier '=' constant_expression
//  ;
// ***** PIM 4 Appendix 1 line 12 *****
//constantDeclaration :	
//  ident '=' constExpression
//  ;
private bool constantDeclaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!identifier(source)) return false;

    consumeWhitespace(source);
    if (!consumeLiteral(source, "=")) return false;

    consumeWhitespace(source);
    return constantExpression(source);
}

// 2.5 Type Declaration

//type_declaration :
//  identifier '=' type_denoter
//  ;
private bool typeDeclaration(Source source) nothrow
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
private bool variableDeclaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!variableIdentifierList(source)) return false;

    consumeWhitespace(source);
    if (!consumeLiteral(source, ":")) return false;

    return typeDenoter(source);
}

//variable_identifier_list :
//  identifier ( machine_address )? ( ',' identifier ( machine_address )? )*
//  ;
private bool variableIdentifierList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    bool lambda() {
        consumeWhitespace(source);
        if (!identifier(source)) return false;

        source.bookmark();
        if (machineAddress(source)) {
            source.commit();
        } else {
            source.rollback();
        }

        return true;
    }

    if (!lambda()) return false;

    while (true) {
        source.bookmark();

        consumeWhitespace(source);
        if (!consumeLiteral(source, ",")) {
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
private bool machineAddress(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "[")) return false;

    if (!valueOfAddressType(source)) return false;

    return consumeLiteral(source, "]");
}

//value_of_address_type :
//  constant_expression
//  ;
private bool valueOfAddressType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return constantExpression(source);
}

// 2.7 Procedure Declaration

//procedure_declaration :
//  proper_procedure_declaration | function_procedure_declaration
//  ;
// ***** PIM 4 Appendix 1 line 72 *****
//procedureDeclaration :
//  procedureHeading ';' block ident
//  ;
private bool procedureDeclaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (functionProcedureDeclaration(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (properProcedureDeclaration(source)) {
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
private bool properProcedureDeclaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!properProcedureHeading(source)) return false;

    consumeWhitespace(source);
    if (!consumeLiteral(source, ";")) return false;

    source.bookmark();
    consumeWhitespace(source);
    if (consumeLiteral(source, "FORWARD")) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    if (!properProcedureBlock(source)) return false;

    consumeWhitespace(source);
    return procedureIdentifier(source);
}

//procedure_identifier :
//  identifier
//  ;
private bool procedureIdentifier(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return identifier(source);
}

// 2.8.1 Function Procedure Declaration

//function_procedure_declaration :
//  function_procedure_heading ';'
//  ( function_procedure_block procedure_identifier | 'FORWARD' )
//  ;
private bool functionProcedureDeclaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!functionProcedureHeading(source)) return false;

    consumeWhitespace(source);
    if (!consumeLiteral(source, ";")) return false;

    source.bookmark();
    consumeWhitespace(source);
    if (consumeLiteral(source, "FORWARD")) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    if (!functionProcedureBlock(source)) return false;

    consumeWhitespace(source);
    return procedureIdentifier(source);
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
private bool localModuleDeclaration(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "MODULE")) return false;

    if (!consumeWhitespace(source)) return false;
    if (!moduleIdentifier(source)) return false;

    source.bookmark();
    if (protection(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    consumeWhitespace(source);
    if (!consumeLiteral(source, ";")) return false;

    if (!importLists(source)) return false;

    source.bookmark();
    if (exportList(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    if (!moduleBlock(source)) return false;

    consumeWhitespace(source);
    if (!moduleIdentifier(source)) return false;

    return true;
}
