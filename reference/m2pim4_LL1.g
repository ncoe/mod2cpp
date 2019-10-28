/* ANTLR v3 Grammar for Modula-2 (PIM4)
 *
 * LL(1) version, derived from 4th Edition of Programming in Modula-2
 *
 * This grammar is a refactored  LL(1) version of the Modula-2 syntax provided
 * in appendix 1 of "Programming in Modula-2", Fourth Edition 1988, by Niklaus
 * Wirth, Springer Verlag,  ISBN 0-387-50150-9.  It follows the naming conven-
 * tions and structure of Wirth's grammar  but has been  refactored to satisfy
 * LL(1) constraints.   The original,  unmodified  grammar  by Wirth  is  also
 * available in ANTLR v3 format as a separate file.
 *
 *
 * Copyright (C) 2009, Benjamin Kowarsch. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * (1) Hosting of  this  file, or any parts thereof, on websites which contain
 *     advertising is expressly forbidden and requires specific prior written
 *     permission. However, the ANTLR project website and university websites
 *     are exempt from this restriction. Exemption may be withdrawn if abused.
 *
 * (2) Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *
 * (3) Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and other materials provided with the distribution.
 *
 * (4) Neither the author's name nor the names of any contributors may be used
 *     to endorse or promote products derived from this software without
 *     specific prior written permission.
 *
 * (5) Where this list of conditions or the following disclaimer, in part or
 *     as a whole is overruled or nullified by applicable law, no permission
 *     is granted to use the software.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,  BUT NOT LIMITED TO,  THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY  AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
 * CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT  LIMITED  TO,  PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA,  OR PROFITS; OR BUSINESS
 * INTERRUPTION)  HOWEVER  CAUSED  AND ON ANY THEORY OF LIABILITY,  WHETHER IN
 * CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */

grammar m2pim4_LL1; // Modula-2 PIM 4 standard

// file version 1.00, July 10, 2009

// Note: an empty semantic action {} is used in lists of alternative terminals
// in order to make ANTLRworks display the alternatives as separate branches.

// strict LL(1)

options {
	backtrack = no;
	k = 1;
}

// Reserved Words

tokens {
	AND            = 'AND';
	ARRAY          = 'ARRAY';
	BEGIN          = 'BEGIN';
	BY             = 'BY';
	CASE           = 'CASE';
	CONST          = 'CONST';
	DEFINITION     = 'DEFINITION';
	DIV            = 'DIV';
	DO             = 'DO';
	ELSE           = 'ELSE';
	ELSIF          = 'ELSIF';
	END            = 'END';
	EXIT           = 'EXIT';
	EXPORT         = 'EXPORT';
	FOR            = 'FOR';
	FROM           = 'FROM';
	IF             = 'IF';
	IMPLEMENTATION = 'IMPLEMENTATION';
	IMPORT         = 'IMPORT';
	IN             = 'IN';
	LOOP           = 'LOOP';
	MOD            = 'MOD';
	MODULE         = 'MODULE';
	NOT            = 'NOT';
	OF             = 'OF';
	OR             = 'OR';
	POINTER        = 'POINTER';
	PROCEDURE      = 'PROCEDURE';
	QUALIFIED      = 'QUALIFIED';
	RECORD         = 'RECORD';
	REPEAT         = 'REPEAT';
	RETURN         = 'RETURN';
	SET            = 'SET';
	THEN           = 'THEN';
	TO             = 'TO';
	TYPE           = 'TYPE';
	UNTIL          = 'UNTIL';
	VAR            = 'VAR';
	WHILE          = 'WHILE';
	WITH           = 'WITH';
}

// ---------------------------------------------------------------------------
// L E X E R   G R A M M A R
// ---------------------------------------------------------------------------

// ***** PIM 4 Appendix 1 line 1 *****

IDENT :
	LETTER ( LETTER | DIGIT )*
	;

// ***** PIM 4 Appendix 1 lines 3-4 *****

INTEGER :
	DIGIT+ |
	OCTAL_DIGIT+  ( 'B' | 'C' {}) |
	DIGIT ( HEX_DIGIT )* 'H'
	;

// ***** PIM 4 Appendix 1 line 5 *****

REAL :
	DIGIT+ '.' DIGIT* SCALE_FACTOR?
	;

// ***** PIM 4 Appendix 1 line 10 *****

// Nore, the formal definition of string in PIM 4 does not match
//       the plain English description of string in the text.
//       => changed to match textual description
STRING :
	'\'' ( CHARACTER | '\"' )* '\'' | '"' (CHARACTER | '\'')* '"'
	;

// ***** PIM 4 provides no formal definition for letter *****

fragment
LETTER :
	'A' .. 'Z' | 'a' .. 'z'
	{} // make ANTLRworks display separate branches
	;

// ***** PIM 4 Appendix 1 line 11 *****

fragment
DIGIT :
	OCTAL_DIGIT | '8' | '9'
	{} // make ANTLRworks display separate branches
	;

// ***** PIM 4 Appendix 1 line 9 *****

fragment
OCTAL_DIGIT : '0' .. '7' ;

// ***** PIM 4 Appendix 1 line 7 *****

fragment
HEX_DIGIT :
	DIGIT | 'A' | 'B' | 'C' | 'D' | 'E' | 'F'
	{} // make ANTLRworks display separate branches
	;

// ***** PIM 4 Appendix 1 line 6 *****

fragment
SCALE_FACTOR :
	'E' ( '+' | '-' {})? DIGIT+
	;

// ***** PIM 4 provides no formal definition for character *****

fragment
CHARACTER :
	DIGIT | LETTER |
	// any printable characters other than single and double quote
	' ' | '!' | '#' | '$' | '%' | '&' | '(' | ')' | '*' | '+' |
	',' | '-' | '.' | ':' | ';' | '<' | '=' | '>' | '?' | '@' |
	'[' | '\\' | ']' | '^' | '_' | '`' | '{' | '|' | '}' | '~'
	{} // make ANTLRworks display separate branches
	;

// ---------------------------------------------------------------------------
// P A R S E R   G R A M M A R
// ---------------------------------------------------------------------------

// ***** PIM 4 Appendix 1 line 1 *****

ident :	IDENT ; // see lexer

// ***** PIM 4 Appendix 1 line 2 *****

number : INTEGER | REAL ; // see lexer

// ***** PIM 4 Appendix 1 lines 3-4 *****

integer : INTEGER ; // see lexer

// ***** PIM 4 Appendix 1 line 5 *****

real : REAL ; // see lexer

// ***** PIM 4 Appendix 1 line 6 *****

scaleFactor : SCALE_FACTOR ; // see lexer

// ***** PIM 4 Appendix 1 line 7 *****

hexDigit : HEX_DIGIT ; // see lexer

// ***** PIM 4 Appendix 1 line 8 *****

digit : DIGIT ; // see lexer

// ***** PIM 4 Appendix 1 line 9 *****

octalDigit : OCTAL_DIGIT ; // see lexer

// ***** PIM 4 Appendix 1 line 10 *****

string : STRING ; // see lexer

// ***** PIM 4 Appendix 1 line 11 *****

qualident :
	ident ( '.' ident )*
	;

// ***** PIM 4 Appendix 1 line 12 *****

constantDeclaration :	
	ident '=' constExpression
	;

// ***** PIM 4 Appendix 1 line 13 *****

constExpression :
	simpleConstExpr ( relation simpleConstExpr )?
	;

// ***** PIM 4 Appendix 1 line 14 *****

relation :
	'=' | '#' | '<>' | '<' | '<=' | '>' | '>=' | 'IN' {}
	;

// ***** PIM 4 Appendix 1 line 15 *****

simpleConstExpr :
	( '+' | '-' {})? constTerm ( addOperator constTerm )*
	;

// ***** PIM 4 Appendix 1 line 16 *****

addOperator :
	'+' | '-' | OR
	{} // make ANTLRworks display separate branches
	;

// ***** PIM 4 Appendix 1 line 17 *****

constTerm :
	constFactor ( mulOperator constFactor )*
	;

// ***** PIM 4 Appendix 1 line 18 *****

mulOperator :
	'*' | '/' | DIV | MOD | AND | '&'
	{} // make ANTLRworks display separate branches
	;

// ***** PIM 4 Appendix 1 lines 19-20 *****

// refactored for LL(1)
//
// Note: PIM 4 text says '~' is a synonym for 'NOT'
//       but the grammar does not actually show it
constFactor :
	number | string | setOrQualident |
	'(' constExpression ')' | ( NOT | '~' {}) constFactor
	;

// new for LL(1)
setOrQualident :
	set | qualident set?
	;

// ***** PIM 4 Appendix 1 line 21 *****

// refactored for LL(1)
set :
	/* qualident has been factored out */
	'{' ( element ( ',' element )* )? '}'
	;

// ***** PIM 4 Appendix 1 line 22 *****

element :
	constExpression ( '..' constExpression )?
	;

// ***** PIM 4 Appendix 1 line 23 *****

typeDeclaration :
	ident '=' type
	;

// ***** PIM 4 Appendix 1 lines 24-25 *****

type :
	simpleType | arrayType | recordType | setType | pointerType | procedureType
	;

// ***** PIM 4 Appendix 1 line 26 *****

simpleType :
	qualident | enumeration | subrangeType
	;

// ***** PIM 4 Appendix 1 line 27 *****

enumeration :
	'(' identList ')'
	;

// ***** PIM 4 Appendix 1 line 28 *****

identList :
	ident ( ',' ident )*
	;

// ***** PIM 4 Appendix 1 line 29 *****

subrangeType :
	'[' constExpression '..' constExpression ']'
	;

// ***** PIM 4 Appendix 1 line 30 *****

arrayType :
	ARRAY simpleType ( ',' simpleType )* OF type
	;

// ***** PIM 4 Appendix 1 line 31 *****

recordType :
	RECORD fieldListSequence END
	;

// ***** PIM 4 Appendix 1 line 32 *****

fieldListSequence :
	fieldList ( ';' fieldList )*
	;

// ***** PIM 4 Appendix 1 lines 33-35 *****

// refactored for LL(1)
fieldList :
	( identList ':' type |
	  CASE ident ( ( ':' | '.' {}) qualident )? OF variant ( '|' variant )*
	  ( ELSE fieldListSequence )?
	  END )?
	;

// ***** PIM 4 Appendix 1 line 36 *****

variant :
	caseLabelList ':' fieldListSequence
	;

// ***** PIM 4 Appendix 1 line 37 *****

caseLabelList :
	caseLabels ( ',' caseLabels )*
	;

// ***** PIM 4 Appendix 1 line 38 *****

caseLabels :
	constExpression ( '..' constExpression )?
	;

// ***** PIM 4 Appendix 1 line 39 *****

setType :
	SET OF simpleType
	;

// ***** PIM 4 Appendix 1 line 40 *****

pointerType :
	POINTER TO type
	;

// ***** PIM 4 Appendix 1 line 41 *****

procedureType :
	PROCEDURE formalTypeList?
	;

// ***** PIM 4 Appendix 1 lines 42-43 *****

formalTypeList :
	'(' ( VAR? formalType ( ',' VAR? formalType )* )? ')'
	( ':' qualident )?
	;

// ***** PIM 4 Appendix 1 line 44 *****

variableDeclaration :
	identList ':' type
	;

// ***** PIM 4 Appendix 1 line 45 *****

// refactored for LL(1)
designator :
	qualident ( designatorTail )?
	;

// new for LL(1)
designatorTail :
	( ( '[' expList ']' | '^' ) ( '.' ident )* )+
	;

// ***** PIM 4 Appendix 1 line 46 *****

expList :
	expression ( ',' expression )*
	;

// ***** PIM 4 Appendix 1 line 47 *****

expression :
	simpleExpression ( relation simpleExpression )?
	;

// ***** PIM 4 Appendix 1 line 48 *****

simpleExpression :
	( '+' | '-' {})? term ( addOperator term )*
	;

// ***** PIM 4 Appendix 1 line 49 *****

term :
	factor ( mulOperator factor )*
	;

// ***** PIM 4 Appendix 1 lines 50-51 *****

// refactored for LL(1)
//
// Note: PIM 4 text says '~' is a synonym for 'NOT'
//       but the grammar does not actually show it
factor :
	number |
	string |
	setOrDesignatorOrProcCall |
	'(' expression ')' | ( NOT | '~' {}) factor
	;

// new for LL(1)
setOrDesignatorOrProcCall :
	set |
	qualident /* <= factored out */
	( set | designatorTail? actualParameters? )
	;

// ***** PIM 4 Appendix 1 line 52 *****

actualParameters :
	'(' expList? ')'
	;

// ***** PIM 4 Appendix 1 lines 53-56 *****

// refactored for LL(1)
statement :
	( assignmentOrProcCall | ifStatement | caseStatement |
	  whileStatement | repeatStatement | loopStatement | forStatement |
	  withStatement | EXIT | RETURN expression? )?
	;

// ***** PIM 4 Appendix 1 line 57 *****

// and

// ***** PIM 4 Appendix 1 line 58 *****

// both replaced by

// new for LL(1)
assignmentOrProcCall :
	designator /* has been factored out */
	( ':=' expression | actualParameters? )
	;

// ***** PIM 4 Appendix 1 line 59 *****

statementSequence :
	statement ( ';' statement )*
	;

// ***** PIM 4 Appendix 1 lines 60-62 *****

ifStatement :
	IF expression THEN statementSequence
	( ELSIF expression THEN statementSequence )*
	( ELSE statementSequence )?
	END
	;

// ***** PIM 4 Appendix 1 lines 63-64 *****

caseStatement :
	CASE expression OF case ( '|' case )*
	( ELSE statementSequence )?
	END
	;

// ***** PIM 4 Appendix 1 line 65 *****

case :
	caseLabelList ':' statementSequence
	;

// ***** PIM 4  Appendix 1 line 66 *****

whileStatement :
	WHILE expression DO statementSequence END
	;

// ***** PIM 4 Appendix 1 line 67 *****

repeatStatement :
	REPEAT statementSequence UNTIL expression
	;

// ***** PIM 4 Appendix 1 lines 68-69 *****

forStatement :
	FOR ident ':=' expression TO expression ( BY constExpression )?
	DO statementSequence END
	;

// ***** PIM 4 Appendix 1 line 70 *****

loopStatement :
	LOOP statementSequence END
	;

// ***** PIM 4 Appendix 1 line 71 *****

withStatement :
	WITH designator DO statementSequence END
	;

// ***** PIM 4 Appendix 1 line 72 *****

procedureDeclaration :
	procedureHeading ';' block ident
	;

// ***** PIM 4 Appendix 1 line 73 *****

procedureHeading :
	PROCEDURE ident formalParameters?
	;

// ***** PIM 4 Appendix 1 line 74 *****

block :
	declaration*
	( BEGIN statementSequence )? END
	;

// ***** PIM 4 Appendix 1 lines 75-78 *****

declaration :
	CONST ( constantDeclaration ';' )* |
	TYPE ( typeDeclaration ';' )* |
	VAR ( variableDeclaration ';' )* |
	procedureDeclaration ';' |
	moduleDeclaration ';'
	;

// ***** PIM 4 Appendix 1 lines 79-80 *****

formalParameters :
	'(' ( fpSection ( ';' fpSection )* )? ')' ( ':' qualident )?
	;

// ***** PIM 4 Appendix 1 line 81 *****

fpSection :
	VAR? identList ':' formalType
	;

// ***** PIM 4 Appendix 1 line 82 *****

formalType :
	( ARRAY OF )? qualident
	;

// ***** PIM 4 Appendix 1 lines 83-84 *****

moduleDeclaration :
	MODULE ident priority? ';'
	importList* exportList?
	block ident
	;

// ***** PIM 4 Appendix 1 line 85 *****

priority :
	'[' constExpression ']'
	;

// ***** PIM 4 Appendix 1 line 86 *****

exportList :
	EXPORT QUALIFIED? identList ';'
	;

// ***** PIM 4 Appendix 1 line 87 *****

importList :
	( FROM ident )? IMPORT identList ';'
	;

// ***** PIM 4 Appendix 1 lines 88-89 *****

definitionModule :
	DEFINITION MODULE ident ';'
	importList* exportList? definition*
	END ident '.'
	;

// ***** PIM 4 Appendix 1 lines 90-93 *****

definition :
	CONST ( constantDeclaration ';' )* |
	TYPE ( ident ( '=' type )? ';' )* |
	VAR ( variableDeclaration ';' )* |
	procedureHeading ';'
	;

// ***** PIM 4 Appendix 1 lines 94-95 *****

programModule :
	MODULE ident priority? ';'
	importList* block ident '.'
	;

// ***** PIM 4 Appendix 1 lines 96-97 *****

compilationUnit :	
	definitionModule | IMPLEMENTATION? programModule
	;

// END OF FILE
