module grammar.lex;

import std.array;
import std.range;

import compiler.source;

public bool consumeLiteral(Source source, const string expected) nothrow in {
    assert(source);
    assert(expected.length > 0);
} body {
    source.bookmark();

    auto end = source.offset + expected.length;
    if (end < source.length) {
        auto actual = source.take(expected.length).array;
        if (expected == actual) {
            source.commit();
            return true;
        }
    }

    source.rollback();
    return false;
}

private bool isWhitespace(Source source) nothrow in {
    assert(source);
} body {
    if (source.empty) return false;

    auto c = source.front;
    return c == ' '
        || c == '\t'
        || c == '\n'
        || c == '\r';
}

public bool consumeWhitespace(Source source) nothrow in {
    assert(source);
} body {
    bool found = false;
    while (isWhitespace(source)) {
        found = true;

        auto c = source.front;
        if (c == '\n') {
            source.popFront();

            source.updateLine();
        } else if (c == '\r') {
            source.popFront();
            if (!source.empty && source.front == '\n') {
                source.popFront();
            }

            source.updateLine();
        } else {
            source.popFront();
        }
    }
    return found;
}

/**
 * Lexer grammer with the ll1 variant first followed by the equivilant iso rule
 */

//COMMENT :
//  '(*' ( : . )* ( COMMENT )* '*)'
//  ;
//todo support parsing comments

//identifier :
//  IDENTIFIER ;
// ***** PIM 4 Appendix 1 line 1 *****
//IDENT :
//  LETTER ( LETTER | DIGIT )*
//  ;
//IDENTIFIER :
//  LETTER ( LETTER | DIGIT )*
//  ;
public bool identifier(Source source) nothrow in {
    assert(source);
} body {
    if (source.empty) return false;

    if (!isLetter(source.front)) return false;
    source.popFront();

    while (!source.empty && (isLetter(source.front) || isDigit(source.front))) {
        source.popFront();
    }
    return true;
}

//whole_number_literal :
//  WHOLE_NUMBER_LITERAL
//  ;
//WHOLE_NUMBER_LITERAL :
//  DIGIT ( DIGIT )* ( OCTAL_DIGIT ( OCTAL_DIGIT )* ( 'B' | 'C' ) )?
//  | DIGIT ( HEX_DIGIT )* 'H'
//  ;
// ***** PIM 4 Appendix 1 lines 3-4 *****
//INTEGER :
//  DIGIT+ |
//  OCTAL_DIGIT+  ( 'B' | 'C' {}) |
//  DIGIT ( HEX_DIGIT )* 'H'
//  ;
public bool wholeNumberLiteral(Source source) nothrow in {
    assert(source);
} body {
    // DIGIT ( HEX_DIGIT )* 'H'
    source.bookmark();
    if (isDigit(source.front)) {
        source.popFront();

        while (isHexDigit(source.front)) {
            source.popFront();
        }

        if (consumeLiteral(source, "H")) {
            source.commit();
            return true;
        }
    } else {
        source.rollback();
    }

    // OCTAL_DIGIT+  ( 'B' | 'C' {})
    source.bookmark();
    if (isOctalDigit(source.front)) {
        source.popFront();

        while (isOctalDigit(source.front)) {
            source.popFront();
        }

        if (consumeLiteral(source, "B") || consumeLiteral(source, "C")) {
            source.commit();
            return true;
        }
    } else {
        source.rollback();
    }

    // DIGIT+
    if (isDigit(source.front)) {
        source.popFront();
    } else {
        return false;
    }
    while (isDigit(source.front)) {
        source.popFront();
    }

    return true;
}

//real_literal :
//  REAL_LITERAL
//  ;
//REAL_LITERAL :
//  DIGIT ( DIGIT )* '.' ( DIGIT )* ( SCALE_FACTOR )?
//  ;
// ***** PIM 4 Appendix 1 line 5 *****
//REAL :
//  DIGIT+ '.' DIGIT* SCALE_FACTOR?
//  ;
public bool realLiteral(Source source) nothrow in {
    assert(source);
} body {
    assert(false, "todo finish this");
}

//string_literal :
//  STRING_LITERAL
//  ;
//STRING_LITERAL :
//  '\'' ( CHARACTER )* '\'' | '"' ( CHARACTER )* '"'
//  ;
// ***** PIM 4 Appendix 1 line 10 *****
// Nore, the formal definition of string in PIM 4 does not match
//       the plain English description of string in the text.
//       => changed to match textual description
//STRING :
//  '\'' ( CHARACTER | '\"' )* '\'' | '"' (CHARACTER | '\'')* '"'
//  ;
public bool stringLiteral(Source source) nothrow in {
    assert(source);
} body {
    source.bookmark();
    if (consumeLiteral(source, "'")) {
        while (isCharacter(source.front)) {
            source.popFront();
        }

        if (consumeLiteral(source, "'")) {
            source.commit();
            return true;
        } else {
            source.rollback();
        }
    } else {
        source.rollback();
    }

    source.bookmark();
    if (consumeLiteral(source, "\"")) {
        while (isCharacter(source.front)) {
            source.popFront();
        }

        if (consumeLiteral(source, "\"")) {
            source.commit();
            return true;
        } else {
            source.rollback();
        }
    } else {
        source.rollback();
    }

    return false;
}

//fragment
//LETTER : '_' | 'A' .. 'Z' | 'a' .. 'z' ;
// ***** PIM 4 provides no formal definition for letter *****
//fragment
//LETTER :
//  'A' .. 'Z' | 'a' .. 'z'
//  {} // make ANTLRworks display separate branches
//  ;
private bool isLetter(ubyte u) nothrow {
    return u == '_'
        || ('A' <= u && u <= 'Z')
        || ('a' <= u && u <= 'z');
}

//fragment
//DIGIT :   OCTAL_DIGIT | '8' | '9' ;
// ***** PIM 4 Appendix 1 line 11 *****
//fragment
//DIGIT :
//  OCTAL_DIGIT | '8' | '9'
//  {} // make ANTLRworks display separate branches
//  ;
private bool isDigit(ubyte u) nothrow {
    return isOctalDigit(u)
        || u == '8'
        || u == '9';
}

//fragment
//OCTAL_DIGIT : '0' .. '7' ;
// ***** PIM 4 Appendix 1 line 9 *****
//fragment
//OCTAL_DIGIT : '0' .. '7' ;
private bool isOctalDigit(ubyte u) nothrow {
    return '0' <= u && u <= '7';
}

//fragment
//HEX_DIGIT : DIGIT | 'A' | 'B' | 'C' | 'D' | 'E' | 'F' ;
// ***** PIM 4 Appendix 1 line 7 *****
//fragment
//HEX_DIGIT :
//  DIGIT | 'A' | 'B' | 'C' | 'D' | 'E' | 'F'
//  {} // make ANTLRworks display separate branches
//  ;
private bool isHexDigit(ubyte u) nothrow {
    return isDigit(u)
        || ('A' <= u && u <= 'F');
}

//fragment
//SCALE_FACTOR :
//  'E' ( '+' | '-' )? DIGIT ( DIGIT )*
//  ;
// ***** PIM 4 Appendix 1 line 6 *****
//fragment
//SCALE_FACTOR :
//  'E' ( '+' | '-' {})? DIGIT+
//  ;
private bool scaleFactor(Source source) nothrow in {
    assert(source);
} body {
    assert(false, "todo finish this");
}

//fragment
//CHARACTER :
//  // any printable characters other than single and double quote
//  ~( '\u0000' .. '\u001f' | '\'' | '"' )
//  ;
// ***** PIM 4 provides no formal definition for character *****
//fragment
//CHARACTER :
//  DIGIT | LETTER |
//  // any printable characters other than single and double quote
//  ' ' | '!' | '#' | '$' | '%' | '&' | '(' | ')' | '*' | '+' |
//  ',' | '-' | '.' | ':' | ';' | '<' | '=' | '>' | '?' | '@' |
//  '[' | '\\' | ']' | '^' | '_' | '`' | '{' | '|' | '}' | '~'
//  {} // make ANTLRworks display separate branches
//  ;
private bool isCharacter(ubyte u) nothrow {
    return ' ' <= u && u <= '~' && u != '"' && u != '\'';
}

/////////////////////////////////////////////////////

//pointer_literal :
//  POINTER_LITERAL
//  ;
//POINTER_LITERAL :
//  ;
