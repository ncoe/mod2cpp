module grammar.program;

import compiler.source;
import compiler.util;
import grammar.block;
import grammar.expression;
import grammar.lex;
import grammar.types;

///////////////////////////////////////////////////////////////////////////////
// 1.1 Programs and Compilation Modules

//compilation_module :
//  program_module | definition_module | implementation_module
//  ;
// ***** PIM 4 Appendix 1 lines 96-97 *****
//compilationUnit :
//  definitionModule | IMPLEMENTATION? programModule
//  ;
public bool compilationUnit(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    size_t highwater;

    source.bookmark();

    source.bookmark();
    if (definitionModule(source)) {
        source.commit();
        source.commit();
        return true;
    } else {
        highwater = source.offset;
        source.rollback();
    }

    source.bookmark();
    if (implementationModule(source)) {
        source.commit();
        source.commit();
        return true;
    } else {
        auto iPos = source.offset;
        if (iPos > highwater) {
            debugWrite(source, "Failed to parse an implementation module, made it to:");
            source.rollback();
            source.rollback();
            return false;
        }
        source.rollback();
    }

    source.bookmark();
    if (programModule(source)) {
        source.commit();
        source.commit();
        return true;
    } else {
        auto pPos = source.offset;
        if (pPos > highwater) {
            debugWrite(source, "Failed to parse a program module module, made it to:");
            source.rollback();
            source.rollback();
            return false;
        }
        source.rollback();
    }

    debugWrite(source, "Failed to parse a definition module, made it to:");
    source.rollback();

    return false;
}

///////////////////////////////////////////////////////////////////////////////
// 1.2 Program Modules

//program_module :
//  'MODULE' module_identifier ( protection )? ';'
//  import_lists module_block module_identifier '.'
//  ;
// ***** PIM 4 Appendix 1 lines 94-95 *****
//programModule :
//  MODULE ident priority? ';'
//  importList* block ident '.'
//  ;
private bool programModule(Source source) nothrow
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

    if (!moduleBlock(source)) return false;

    consumeWhitespace(source);
    if (!moduleIdentifier(source)) return false;

    consumeWhitespace(source);
    if (!consumeLiteral(source, ".")) return false;

    return true;
}

//module_identifier :
//  identifier
//  ;
public bool moduleIdentifier(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return identifier(source);
}

//protection :
//  '[' protection_expression ']'
//  ;
// ***** PIM 4 Appendix 1 line 85 *****
//priority :
//  '[' constExpression ']'
//  ;
public bool protection(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "[")) return false;

    if (!protectionExpression(source)) return false;

    consumeWhitespace(source);
    return consumeLiteral(source, "]");
}

//protection_expression :
//  constant_expression
//  ;
private bool protectionExpression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return constantExpression(source);
}

///////////////////////////////////////////////////////////////////////////////
// 1.3 Definition Module

//definition_module :
//  'DEFINITION' 'MODULE' module_identifier ';'
//  import_lists definitions 'END' module_identifier '.'
//  ;
// ***** PIM 4 Appendix 1 lines 88-89 *****
//definitionModule :
//  DEFINITION MODULE ident ';'
//  importList* exportList? definition*
//  END ident '.'
//  ;
private bool definitionModule(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "DEFINITION")) return false;

    if (!consumeWhitespace(source)) return false;
    if (!consumeLiteral(source, "MODULE")) return false;

    if (!consumeWhitespace(source)) return false;
    if (!moduleIdentifier(source)) return false;

    consumeWhitespace(source);
    if (!consumeLiteral(source, ";")) return false;

    if (!importLists(source)) return false;

    //todo definitions

    consumeWhitespace(source);
    if (!consumeLiteral(source, "END")) return false;

    consumeWhitespace(source);
    if (!moduleIdentifier(source)) return false;

    consumeWhitespace(source);
    if (!consumeLiteral(source, ".")) return false;

    return true;
}

///////////////////////////////////////////////////////////////////////////////
// 1.4 Implementation Module

//implementation_module :
//  'IMPLEMENTATION' 'MODULE' module_identifier ( protection )? ';'
//  import_lists module_block module_identifier '.'
//  ;
// ***** PIM 4 Appendix 1 lines 96-97 *****
//compilationUnit :	
//  definitionModule | IMPLEMENTATION? programModule
//  ;
private bool implementationModule(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "IMPLEMENTATION")) return false;

    if (!consumeWhitespace(source)) return false;
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

    if (!moduleBlock(source)) return false;

    consumeWhitespace(source);
    if (!moduleIdentifier(source)) return false;

    if (!consumeLiteral(source, ".")) return false;

    return true;
}

///////////////////////////////////////////////////////////////////////////////
// 1.5 Import Lists

//import_lists :
//  ( import_list )*
//  ;
public bool importLists(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    while (true) {
        source.bookmark();

        if (!importList(source)) {
            source.rollback();
            break;
        }

        source.commit();
    }

    return true;
}

///////////////////////////////////////////////////////////////////////////////
// 1.5.1 Import List

//import_list :
//  simple_import | unqualified_import
//  ;
// ***** PIM 4 Appendix 1 line 87 *****
//importList :
//  ( FROM ident )? IMPORT identList ';'
//  ;
private bool importList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (simpleImport(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return unqualifiedImport(source);
}

///////////////////////////////////////////////////////////////////////////////
// 1.5.2 Simple Import

//simple_import :
//  'IMPORT' identifier_list ';'
//  ;
// ***** PIM 4 Appendix 1 line 87 *****
//importList :
//  ( FROM ident )? IMPORT identList ';'
//  ;
//production #10 (objm2)
//importList :
//  ( FROM moduleId IMPORT ( identList | '*' ) |
//    IMPORT ident '+'? ( ',' ident '+'? )* ) ';'
//  ;
private bool simpleImport(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "IMPORT")) return false;

    if (!consumeWhitespace(source)) return false;

    source.bookmark();
    if (identifierList(source)) {
        source.commit();
    } else {
        source.rollback();

        source.bookmark();
        if (consumeLiteral(source, "*")) {
            source.commit();
        } else {
            source.rollback();
            return false;
        }
    }

    consumeWhitespace(source);
    if (!consumeLiteral(source, ";")) return false;

    return true;
}

///////////////////////////////////////////////////////////////////////////////
// 1.5.3 Unqualified Import

//unqualified_import :
//  'FROM' module_identifier 'IMPORT' identifier_list ';'
//  ;
// ***** PIM 4 Appendix 1 line 87 *****
//importList :
//  ( FROM ident )? IMPORT identList ';'
//  ;
//production #10 (objm2)
//importList :
//  ( FROM moduleId IMPORT ( identList | '*' ) |
//    IMPORT ident '+'? ( ',' ident '+'? )* ) ';'
//  ;
private bool unqualifiedImport(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "FROM")) return false;

    if (!consumeWhitespace(source)) return false;
    if (!moduleIdentifier(source)) return false;

    if (!consumeWhitespace(source)) return false;
    if (!consumeLiteral(source, "IMPORT")) return false;

    if (!consumeWhitespace(source)) return false;

    source.bookmark();
    if (identifierList(source)) {
        source.commit();
    } else {
        source.rollback();

        source.bookmark();
        if (consumeLiteral(source, "*")) {
            source.commit();
        } else {
            source.rollback();
            return false;
        }
    }

    consumeWhitespace(source);
    if (!consumeLiteral(source, ";")) return false;

    return true;
}

///////////////////////////////////////////////////////////////////////////////
// 1.6 Export Lists

//export_list :
//  unqualified_export | qualified_export
//  ;
// ***** PIM 4 Appendix 1 line 86 *****
//exportList :
//  EXPORT QUALIFIED? identList ';'
//  ;
public bool exportList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (qualifiedExport(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (unqualifiedExport(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return false;
}

///////////////////////////////////////////////////////////////////////////////
// 1.6.1 Unqualified Export

//unqualified_export :
//  'EXPORT' identifier_list ';'
//  ;
private bool unqualifiedExport(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "EXPORT")) return false;

    if (!consumeWhitespace(source)) return false;
    if (!identifierList(source)) return false;

    consumeWhitespace(source);
    if (!consumeLiteral(source, ";")) return false;

    return true;
}

///////////////////////////////////////////////////////////////////////////////
// 1.6.2 Qualified Export

//qualified_export :
//  'EXPORT' 'QUALIFIED' identifier_list ';'
//  ;
private bool qualifiedExport(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    consumeWhitespace(source);
    if (!consumeLiteral(source, "EXPORT")) return false;

    if (!consumeWhitespace(source)) return false;
    if (!consumeLiteral(source, "QUALIFIED")) return false;

    if (!consumeWhitespace(source)) return false;
    if (!identifierList(source)) return false;

    consumeWhitespace(source);
    if (!consumeLiteral(source, ";")) return false;

    return true;
}
