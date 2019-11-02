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
public bool typeDenoter(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (newType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return typeIdentifier(source);
}

//ordinal_type_denoter :
//  ordinal_type_identifier | new_ordinal_type
//  ;
private bool ordinalTypeDenoter(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (newOrdinalType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return ordinalTypeIdentifier(source);
}

// 3.1 Type Identifier

//type_identifier :
//  qualified_identifier 
//  ;
public bool typeIdentifier(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return qualifiedIdentifier(source);
}

//ordinal_type_identifier :
//  type_identifier
//  ;
private bool ordinalTypeIdentifier(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return typeIdentifier(source);
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
private bool newType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (arrayType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (packedsetType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (pointerType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (procedureType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (recordType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (setType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return newOrdinalType(source);
}

//new_ordinal_type :
//  enumeration_type | subrange_type
//  ;
// ***** PIM 4 Appendix 1 line 26 *****
//simpleType :
//  qualident | enumeration | subrangeType
//  ;
private bool newOrdinalType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (enumerationType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return subrangeType(source);
}

// 3.2.1 Enumeration Type

//enumeration_type :
//  '(' identifier_list ')'
//  ;
// ***** PIM 4 Appendix 1 line 27 *****
//enumeration :
//  '(' identList ')'
//  ;
private bool enumerationType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!consumeSymbol(source, "(")) return false;
    if (!identifierList(source)) return false;
    return consumeSymbol(source, ")");
}

//identifier_list :
//  identifier ( ',' identifier )*
//  ;
public bool identifierList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!identifier(source)) return false;

    while (true) {
        source.bookmark();

        if (!consumeSymbol(source, ",")) {
            source.rollback();
            break;
        }

        if (!identifier(source)) {
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
private bool subrangeType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (rangeType(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    if (!consumeSymbol(source, "[")) return false;
    if (!constantExpression(source)) return false;
    if (!consumeSymbol(source, "..")) return false;
    if (!constantExpression(source)) return false;
    return consumeSymbol(source, "]");
}

//range_type :
//  ordinal_type_identifier
//  ;
private bool rangeType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return ordinalTypeIdentifier(source);
}

// 3.2.3 Set Type

//set_type :
//  'SET' 'OF' base_type
//  ;
// ***** PIM 4 Appendix 1 line 39 *****
//setType :
//  SET OF simpleType
//  ;
private bool setType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!consumeKeyword(source, "SET")) return false;
    if (!consumeKeyword(source, "OF")) return false;
    return baseType(source);
}

//base_type :
//  ordinal_type_denoter
//  ;
private bool baseType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return ordinalTypeDenoter(source);
}

// 3.2.4 Packedset Type

//packedset_type :
//  'PACKEDSET' 'OF' base_type
//  ;
private bool packedsetType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!consumeKeyword(source, "PACKEDSET")) return false;
    if (!consumeKeyword(source, "OF")) return false;
    return baseType(source);
}

// 3.2.5 Pointer Type

//pointer_type :
//  'POINTER' 'TO' bound_type
//  ;
// ***** PIM 4 Appendix 1 line 40 *****
//pointerType :
//  POINTER TO type
//  ;
private bool pointerType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!consumeKeyword(source, "POINTER")) return false;
    if (!consumeKeyword(source, "TO")) return false;
    return boundType(source);
}

//bound_type :
//  type_denoter
//  ;
private bool boundType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return typeDenoter(source);
}

// 3.2.6 Procedure Type

//procedure_type :
//  proper_procedure_type | function_procedure_type
//  ;
// ***** PIM 4 Appendix 1 line 41 *****
//procedureType :
//  PROCEDURE formalTypeList?
//  ;
private bool procedureType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (functionPocedureType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return properPocedureType(source);
}

//fragment
//proper_procedure_type :
//  'PROCEDURE' '(' ( formal_parameter_type_list )? ')'
//  ;
private bool properPocedureType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!consumeKeyword(source, "PROCEDURE")) return false;
    if (!consumeSymbol(source, "(")) return false;

    source.bookmark();
    if (formalParamterTypeList(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    return consumeSymbol(source, ")");

}

//function_procedure_type :
//  'PROCEDURE' '(' ( formal_parameter_type_list )? ')'
//  ':' function_result_type
//  ;
private bool functionPocedureType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!consumeKeyword(source, "PROCEDURE")) return false;
    if (!consumeSymbol(source, "(")) return false;

    source.bookmark();
    if (formalParamterTypeList(source)) {
        source.commit();
    } else {
        source.rollback();
    }

    if (!consumeSymbol(source, ")")) return false;
    if (!consumeSymbol(source, ":")) return false;
    return functionResultType(source);
}

//formal_parameter_type_list :
//  formal_parameter_type ( ',' formal_parameter_type )*
//  ;
private bool formalParamterTypeList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!formalParamterType(source)) return false;

    while (true) {
        source.bookmark();

        if (!consumeSymbol(source, ",")) {
            source.rollback();
            break;
        }

        if (!formalParamterType(source)) {
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
private bool formalParamterType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (variableFormalType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return valueFormalType(source);
}

//variable_formal_type :
//  'VAR' formal_type
//  ;
private bool variableFormalType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (consumeKeyword(source, "VAR")) return false;
    return formalType(source);
}

//value_formal_type :
//  formal_type
//  ;
private bool valueFormalType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return formalType(source);
}

// 3.2.7 Formal Type

//formal_type :
//  type_identifier | open_array_formal_type
//  ;
// ***** PIM 4 Appendix 1 line 82 *****
//formalType :
//  ( ARRAY OF )? qualident
//  ;
public bool formalType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (openArrayFormalType(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return typeIdentifier(source);
}

//open_array_formal_type :
//  'ARRAY' 'OF' ( 'ARRAY' 'OF' )* type_identifier
//  ;
private bool openArrayFormalType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!consumeKeyword(source, "ARRAY")) return false;
    if (!consumeKeyword(source, "OF")) return false;

    while (true) {
        source.bookmark();

        if (!consumeKeyword(source, "ARRAY")) {
            source.rollback();
            break;
        }
        if (!consumeKeyword(source, "OF")) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return typeIdentifier(source);
}

// 3.2.8 Array Type

//array_type :
//  'ARRAY' index_type ( ',' index_type )* 'OF' component_type
//  ;
// ***** PIM 4 Appendix 1 line 30 *****
//arrayType :
//  ARRAY simpleType ( ',' simpleType )* OF type
//  ;
private bool arrayType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!consumeKeyword(source, "ARRAY")) return false;
    if (!indexType(source)) return false;

    while (true) {
        source.bookmark();

        if (!consumeSymbol(source, ",")) {
            source.rollback();
            break;
        }

        if (!indexType(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    if (!consumeKeyword(source, "OF")) return false;
    return componentType(source);
}

//index_type :
//  ordinal_type_denoter
//  ;
private bool indexType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return ordinalTypeDenoter(source);
}

//component_type :
//  type_denoter
//  ;
private bool componentType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return typeDenoter(source);
}

// 3.2.9 Record Type

//record_type :
//  'RECORD' field_list 'END'
//  ;
// ***** PIM 4 Appendix 1 line 31 *****
//recordType :
//  RECORD fieldListSequence END
//  ;
private bool recordType(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!consumeKeyword(source, "RECORD")) return false;

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
