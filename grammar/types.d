module grammar.types;

import compiler.source;
import compiler.util;
import grammar.expression;
import grammar.lex;
import grammar.qualified;

// 3 Types

//type_denoter :
//  type_identifier | new_type
//  ;
public bool parseTypeDenoter(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (parseNewType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return parseTypeIdentifier(source);
}

//ordinal_type_denoter :
//  ordinal_type_identifier | new_ordinal_type
//  ;
private bool parseOrdinalTypeDenoter(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (parseNewOrdinalType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return parseOrdinalTypeIdentifier(source);
}

// 3.1 Type Identifier

//type_identifier :
//  qualified_identifier 
//  ;
public bool parseTypeIdentifier(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseQualifiedIdentifier(source);
}

//ordinal_type_identifier :
//  type_identifier
//  ;
private bool parseOrdinalTypeIdentifier(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseTypeIdentifier(source);
}

// 3.2 New Type

//new_type :
//  new_ordinal_type | set_type | packedset_type | pointer_type |
//  procedure_type | array_type | record_type
//  ;
// ***** PIM 4 Appendix 1 lines 24-25 *****
//type :
//  simpleType | arrayType | recordType | setType | pointerType | procedureType
//  ;
private bool parseNewType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (parseArrayType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (parsePackedsetType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (parsePointerType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (parseProcedureType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (parseRecordType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (parseSetType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return parseNewOrdinalType(source);
}

//new_ordinal_type :
//  enumeration_type | subrange_type
//  ;
// ***** PIM 4 Appendix 1 line 26 *****
//simpleType :
//  qualident | enumeration | subrangeType
//  ;
private bool parseNewOrdinalType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (parseEnumerationType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return parseSubrangeType(source);
}

// 3.2.1 Enumeration Type

//enumeration_type :
//  '(' identifier_list ')'
//  ;
// ***** PIM 4 Appendix 1 line 27 *****
//enumeration :
//  '(' identList ')'
//  ;
private bool parseEnumerationType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexSymbol(source, "(")) return false;
    if (!parseIdentifierList(source)) return false;
    return lexSymbol(source, ")");
}

//identifier_list :
//  identifier ( ',' identifier )*
//  ;
public bool parseIdentifierList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexIdentifier(source)) return false;

    while (true) {
        source.bookmark();

        if (!lexSymbol(source, ",")) {
            source.rollback();
            break;
        }

        if (!lexIdentifier(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}

// 3.2.2 Subrange Type

//subrange_type :
//  ( range_type )? '[' constant_expression '..' constant_expression ']'
//  ;
// ***** PIM 4 Appendix 1 line 29 *****
//subrangeType :
//  '[' constExpression '..' constExpression ']'
//  ;
private bool parseSubrangeType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (parseRangeType(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    if (!lexSymbol(source, "[")) return false;
    if (!parseConstantExpression(source)) return false;
    if (!lexSymbol(source, "..")) return false;
    if (!parseConstantExpression(source)) return false;
    return lexSymbol(source, "]");
}

//range_type :
//  ordinal_type_identifier
//  ;
private bool parseRangeType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseOrdinalTypeIdentifier(source);
}

// 3.2.3 Set Type

//set_type :
//  'SET' 'OF' base_type
//  ;
// ***** PIM 4 Appendix 1 line 39 *****
//setType :
//  SET OF simpleType
//  ;
private bool parseSetType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "SET")) return false;
    if (!lexKeyword(source, "OF")) return false;
    return parseBaseType(source);
}

//base_type :
//  ordinal_type_denoter
//  ;
private bool parseBaseType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseOrdinalTypeDenoter(source);
}

// 3.2.4 Packedset Type

//packedset_type :
//  'PACKEDSET' 'OF' base_type
//  ;
private bool parsePackedsetType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "PACKEDSET")) return false;
    if (!lexKeyword(source, "OF")) return false;
    return parseBaseType(source);
}

// 3.2.5 Pointer Type

//pointer_type :
//  'POINTER' 'TO' bound_type
//  ;
// ***** PIM 4 Appendix 1 line 40 *****
//pointerType :
//  POINTER TO type
//  ;
private bool parsePointerType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "POINTER")) return false;
    if (!lexKeyword(source, "TO")) return false;
    return parseBoundType(source);
}

//bound_type :
//  type_denoter
//  ;
private bool parseBoundType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseTypeDenoter(source);
}

// 3.2.6 Procedure Type

//procedure_type :
//  proper_procedure_type | function_procedure_type
//  ;
// ***** PIM 4 Appendix 1 line 41 *****
//procedureType :
//  PROCEDURE formalTypeList?
//  ;
private bool parseProcedureType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (parseFunctionPocedureType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return parseProperPocedureType(source);
}

//fragment
//proper_procedure_type :
//  'PROCEDURE' '(' ( formal_parameter_type_list )? ')'
//  ;
private bool parseProperPocedureType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "PROCEDURE")) return false;
    if (!lexSymbol(source, "(")) return false;

    source.bookmark();
    if (parseFormalParamterTypeList(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    return lexSymbol(source, ")");

}

//function_procedure_type :
//  'PROCEDURE' '(' ( formal_parameter_type_list )? ')'
//  ':' function_result_type
//  ;
private bool parseFunctionPocedureType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "PROCEDURE")) return false;
    if (!lexSymbol(source, "(")) return false;

    source.bookmark();
    if (parseFormalParamterTypeList(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    if (!lexSymbol(source, ")")) return false;
    if (!lexSymbol(source, ":")) return false;
    return parseFunctionResultType(source);
}

//formal_parameter_type_list :
//  formal_parameter_type ( ',' formal_parameter_type )*
//  ;
private bool parseFormalParamterTypeList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!parseFormalParamterType(source)) return false;

    while (true) {
        source.bookmark();

        if (!lexSymbol(source, ",")) {
            source.rollback();
            break;
        }

        if (!parseFormalParamterType(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}

//formal_parameter_type :
//  variable_formal_type | value_formal_type
//  ;
private bool parseFormalParamterType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (parseVariableFormalType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return parseValueFormalType(source);
}

//variable_formal_type :
//  'VAR' formal_type
//  ;
private bool parseVariableFormalType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (lexKeyword(source, "VAR")) return false;
    return parseFormalType(source);
}

//value_formal_type :
//  formal_type
//  ;
private bool parseValueFormalType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseFormalType(source);
}

// 3.2.7 Formal Type

//formal_type :
//  type_identifier | open_array_formal_type
//  ;
// ***** PIM 4 Appendix 1 line 82 *****
//formalType :
//  ( ARRAY OF )? qualident
//  ;
public bool parseFormalType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (parseOpenArrayFormalType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return parseTypeIdentifier(source);
}

//open_array_formal_type :
//  'ARRAY' 'OF' ( 'ARRAY' 'OF' )* type_identifier
//  ;
private bool parseOpenArrayFormalType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "ARRAY")) return false;
    if (!lexKeyword(source, "OF")) return false;

    while (true) {
        source.bookmark();

        if (!lexKeyword(source, "ARRAY")) {
            source.rollback();
            break;
        }
        if (!lexKeyword(source, "OF")) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return parseTypeIdentifier(source);
}

// 3.2.8 Array Type

//array_type :
//  'ARRAY' index_type ( ',' index_type )* 'OF' component_type
//  ;
// ***** PIM 4 Appendix 1 line 30 *****
//arrayType :
//  ARRAY simpleType ( ',' simpleType )* OF type
//  ;
private bool parseArrayType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "ARRAY")) return false;
    if (!parseIndexType(source)) return false;

    while (true) {
        source.bookmark();

        if (!lexSymbol(source, ",")) {
            source.rollback();
            break;
        }

        if (!parseIndexType(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    if (!lexKeyword(source, "OF")) return false;
    return parseComponentType(source);
}

//index_type :
//  ordinal_type_denoter
//  ;
private bool parseIndexType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseOrdinalTypeDenoter(source);
}

//component_type :
//  type_denoter
//  ;
private bool parseComponentType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseTypeDenoter(source);
}

// 3.2.9 Record Type

//record_type :
//  'RECORD' field_list 'END'
//  ;
// ***** PIM 4 Appendix 1 line 31 *****
//recordType :
//  RECORD fieldListSequence END
//  ;
private bool parseRecordType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "RECORD")) return false;

    debugWrite(source, "End of Implementation");
    assert(false, "todo finish this");

    //consumeWhitespace(source);
    //if (!consumeLiteral(source, "END")) return false;
}

//field_list :
//  fields ( ';' fields )*
//  ;
// ***** PIM 4 Appendix 1 line 32 *****
//fieldListSequence :
//  fieldList ( ';' fieldList )*
//  ;

//fields :
//  ( fixed_fields | variant_fields )?
//  ;
// ***** PIM 4 Appendix 1 lines 33-35 *****
// refactored for LL(1)
//fieldList :
//  ( identList ':' type |
//    CASE ident ( ( ':' | '.' {}) qualident )? OF variant ( '|' variant )*
//   ( ELSE fieldListSequence )?
//   END )?
//;

//fixed_fields :
//  identifier_list ':' field_type
//  ;

//field_type :
//  type_denoter
//  ;

//variant_fields :
//  'CASE' ( tag_identifier )? ':' tag_type 'OF' variant_list 'END'
//  ;

//tag_identifier :
//  identifier
//  ;

//tag_type :
//  ordinal_type_identifier
//  ;

//variant_list :
//  variant ( '|' variant )* ( variant_else_part )?
//  ;

//variant_else_part :
//  'ELSE' field_list
//  ;

//variant :
//  ( variant_label_list ':' field_list )?
//  ;

//variant_label_list :
//  variant_label ( '.' variant_label )*
//  ;

//variant_label :
//  constant_expression ( '..' constant_expression )?
//  ;
