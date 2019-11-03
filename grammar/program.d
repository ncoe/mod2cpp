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
public bool parseCompilationUnit(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    size_t highwater;

    source.bookmark();

    source.bookmark();
    if (parseDefinitionModule(source)) {
        source.commit();
        source.commit();
        return true;
    } else {
        highwater = source.offset;
        source.rollback();
    }

    source.bookmark();
    if (parseImplementationModule(source)) {
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
    if (parseProgramModule(source)) {
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
private bool parseProgramModule(Source source) nothrow
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
    if (!parseModuleBlock(source)) return false;
    if (!parseModuleIdentifier(source)) return false;
    return lexSymbol(source, ".");
}

//module_identifier :
//  identifier
//  ;
public bool parseModuleIdentifier(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return cast(bool) lexIdentifier(source);
}

//protection :
//  '[' protection_expression ']'
//  ;
// ***** PIM 4 Appendix 1 line 85 *****
//priority :
//  '[' constExpression ']'
//  ;
public bool parseProtection(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexSymbol(source, "[")) return false;
    if (!parseProtectionExpression(source)) return false;
    return lexSymbol(source, "]");
}

//protection_expression :
//  constant_expression
//  ;
private bool parseProtectionExpression(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    return parseConstantExpression(source);
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
private bool parseDefinitionModule(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "DEFINITION")) return false;
    if (!lexKeyword(source, "MODULE")) return false;
    if (!parseModuleIdentifier(source)) return false;
    if (!lexSymbol(source, ";")) return false;
    if (!parseImportLists(source)) return false;

    //todo definitions

    if (!lexKeyword(source, "END")) return false;
    if (!parseModuleIdentifier(source)) return false;
    return lexSymbol(source, ".");
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
private bool parseImplementationModule(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "IMPLEMENTATION")) return false;
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
    if (!parseModuleBlock(source)) return false;
    if (!parseModuleIdentifier(source)) return false;
    return lexSymbol(source, ".");
}

///////////////////////////////////////////////////////////////////////////////
// 1.5 Import Lists

//import_lists :
//  ( import_list )*
//  ;
public bool parseImportLists(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    while (true) {
        source.bookmark();

        if (!parseImportList(source)) {
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
private bool parseImportList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (parseSimpleImport(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    return parseUnqualifiedImport(source);
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
private bool parseSimpleImport(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "IMPORT")) return false;

    source.bookmark();
    if (parseIdentifierList(source)) {
        source.commit();
    } else {
        source.rollback();

        source.bookmark();
        if (lexSymbol(source, "*")) {
            source.commit();
        } else {
            source.rollback();
            return false;
        }
    }

    return lexSymbol(source, ";");
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
private bool parseUnqualifiedImport(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "FROM")) return false;
    if (!parseModuleIdentifier(source)) return false;
    if (!lexKeyword(source, "IMPORT")) return false;

    source.bookmark();
    if (parseIdentifierList(source)) {
        source.commit();
    } else {
        source.rollback();

        source.bookmark();
        if (lexSymbol(source, "*")) {
            source.commit();
        } else {
            source.rollback();
            return false;
        }
    }

    return lexSymbol(source, ";");
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
public bool parseExportList(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    source.bookmark();
    if (parseQualifiedExport(source)) {
        source.commit();
        return true;
    } else {
        source.rollback();
    }

    source.bookmark();
    if (parseUnqualifiedExport(source)) {
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
private bool parseUnqualifiedExport(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "EXPORT")) return false;
    if (!parseIdentifierList(source)) return false;
    return lexSymbol(source, ";");
}

///////////////////////////////////////////////////////////////////////////////
// 1.6.2 Qualified Export

//qualified_export :
//  'EXPORT' 'QUALIFIED' identifier_list ';'
//  ;
private bool parseQualifiedExport(Source source) nothrow
in (source, "Why is the source null?")
do {
    const initDepth = source.depth();
    scope(exit) assertEqual(initDepth, source.depth());

    if (!lexKeyword(source, "EXPORT")) return false;
    if (!lexKeyword(source, "QUALIFIED")) return false;
    if (!parseIdentifierList(source)) return false;
    return lexSymbol(source, ";");
}
