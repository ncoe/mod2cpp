/* ANTLR v3 Grammar for Objective Modula-2, status: May 24, 2010
 *
 *  Copyright (C) 2010 Benjamin Kowarsch. All rights reserved.
 *
 *  License:
 *
 *  Permission is hereby granted to review and test this software for the sole
 *  purpose of supporting the effort by the licensor to define and develop the
 *  Objective Modula-2 language. It is not permissible under any circumstances
 *  to  use the software  for the purpose  of creating derivative languages or 
 *  dialects.  This permission is valid until 31 December 2010, 24:00h GMT.
 *
 *  Future licensing:
 *
 *  The licensor undertakes to eventually release this software under a proper
 *  open source license  AFTER  the Objective Modula-2 language definition has
 *  been finalised and a conforming and working reference compiler completed.
 *
 *  More information about Objective Modula-2:
 *
 *  http://objective.modula2.net
 *
 */

grammar objm2; // Objective Modula-2

// Note: An empty semantic action {} is used in lists of alternative terminals
// in order to make ANTLRworks display the alternatives as separate branches.
// A trailing comment /* extension */ is used within rules to indicate rules
// or lines which represent Objective Modula-2 specific language extensions.


options {

// *** strict LL(1) ***

	backtrack = no;
	k = 1;
}


tokens {
	
// *** R10 Core Language Reserved Words, 42 tokens ***

	ALIAS          = 'ALIAS';
	AND            = 'AND';
	ARRAY          = 'ARRAY';
	ASSOCIATIVE    = 'ASSOCIATIVE';
	BEGIN          = 'BEGIN';
	BINDINGS       = 'BINDINGS';
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
	OPAQUE         = 'OPAQUE';
	OR             = 'OR';
	POINTER        = 'POINTER';
	PROCEDURE      = 'PROCEDURE';
	RECORD         = 'RECORD';
	REPEAT         = 'REPEAT';
	RETURN         = 'RETURN';
	SET            = 'SET';
	THEN           = 'THEN';
	TO             = 'TO';
	TYPE           = 'TYPE';
	UNTIL          = 'UNTIL';
	VAR            = 'VAR';
	VARIADIC       = 'VARIADIC';
	WHILE          = 'WHILE';

// *** Objective Modula-2 Reserved Words, 16 tokens ***

	BYCOPY         = 'BYCOPY';
	BYREF          = 'BYREF';
	CLASS          = 'CLASS';
	CONTINUE       = 'CONTINUE';
	CRITICAL       = 'CRITICAL';
	INOUT          = 'INOUT';
	METHOD         = 'METHOD';
	ON             = 'ON';
	OPTIONAL       = 'OPTIONAL';
	OUT            = 'OUT';
	PRIVATE        = 'PRIVATE';
	PROTECTED      = 'PROTECTED';
	PROTOCOL       = 'PROTOCOL';
	PUBLIC         = 'PUBLIC';
	SUPER          = 'SUPER';
	TRY            = 'TRY';

// *** R10 Core Language Defined Pragma Identifiers, 10 tokens ***

	IF             = 'IF';
	ELSIF          = 'ELSIF';
	ELSE           = 'ELSE';
	ENDIF          = 'ENDIF';
	INFO           = 'INFO';
	WARN           = 'WARN';
	ERROR          = 'ERROR';
	FATAL          = 'FATAL';
	ALIGN          = 'ALIGN';
	FOREIGN        = 'FOREIGN';
	MAKE           = 'MAKE';
	INLINE         = 'INLINE';
	NOINLINE       = 'NOINLINE';
	VOLATILE       = 'VOLATILE';

// *** Objective Modula-2 Defined Pragma Identifiers, 4 tokens ***

	FRAMEWORK      = 'FRAMEWORK';
	IBACTION       = 'IBAction';
	IBOUTLET       = 'IBOutlet';
	QUALIFIED      = 'QUALIFIED';

// *** Special Characters, 3 tokens ***

	BACKSLASH      = '\\';
	SINGLE_QUOTE   = '\'';
	DOUBLE_QUOTE   = '\"';

// *** Ignore Characters, 3 tokens ***

	ASCII_TAB      = '\t';
	ASCII_LF       = '\n';
	ASCII_CR       = '\r';
}


// ---------------------------------------------------------------------------
// N O N - T E R M I N A L   S Y M B O L S
// ---------------------------------------------------------------------------
// 78 productions, 25 aliases

// *** Compilation Units ***

// production #1
compilationUnit :	
	programModule | definitionOfBindings |
	definitionOfModule | implementationOfModule | 
	protocolModule /* extension */
	;

// production #2
definitionOfBindings :
	BINDINGS FOR semanticType ';'
	bindingsHeader bindings*
	END semanticType '.'
	;

// production #3
programModule :
	MODULE moduleId ( '[' priority ']' )? ';'
	importList* block moduleId '.'
	;

// production #4
definitionOfModule :
	DEFINITION MODULE moduleId ( '[' semanticType ']' )? ';'
	importList* definition*
	END moduleId '.'
	;

// production #5
implementationOfModule :
	IMPLEMENTATION programModule
	;

// production #6
protocolModule : /* extension */
	PROTOCOL protocolId ( '(' adoptedProtocols ')' )? ';'
	importList* ( OPTIONAL? methodHeader ';' )*
	END protocolId '.'
	;

// alias
moduleId : ident ;

// alias
priority : constExpression ;

// alias
semanticType : ident ;

// alias
protocolId : ident ;

// alias
adoptedProtocols : identList ;

// *** Bindings, Import Lists, Blocks, Declarations, Definitions ***

// production #7
bindingsHeader :
	TYPE '=' ( RECORD | OPAQUE RECORD? ( ':=' ( literalType | '{' '}' ) )? ) ';'
	;

// production #8
bindings :
    ( CONST '[' bindableIdent ']' |
	  PROCEDURE '[' ( bindableOperator | bindableIdent ) ']' ) ';' 
	;

// production #9
bindableOperator :
	DIV | MOD | IN | FOR | TO | FROM |
	':=' | '::' | '.' | '!' | '+' | '-' | '*' | '/' | '=' | '<' | '>'
	{} // make ANTLRworks display separate branches
	;

// alias
bindableIdent : ident ;
// TMIN, TMAX, ABS, NEG, ODD, COUNT, LENGTH, NEW, DISPOSE

// alias
literalType : ident ;

// production #10
importList :
	( FROM moduleId IMPORT ( identList | '*' ) |
	IMPORT ident '+'? ( ',' ident '+'? )* ) ';'
	;

// production #11
block :
	declaration*
	( BEGIN statementSequence )? END
	;

// production #12
declaration :
	CONST ( constantDeclaration ';' )* |
	TYPE ( ident '=' type ';' )* |
	VAR ( variableDeclaration ';' )* |
	procedureDeclaration ';'
	;

// production #13
definition :
	CONST ( ( '[' ident ']' )? constantDeclaration ';' )* |
	TYPE ( ident '=' ( type | OPAQUE recordType? ) ';' )* |
	VAR ( variableDeclaration ';' )* |
	procedureHeader ';'
	;

// *** Constant Declarations ***

// production #14
constantDeclaration :	
	ident '=' constExpression // no type identifiers
	;

// *** Type Declarations ***

// production #15
type :
	( ALIAS OF | '[' constExpression '..' constExpression ']' OF )? namedType |
	anonymousType | enumerationType | recordType | setType |
	classType /* extension */
	;

// alias
namedType : qualident ;

// production #16
anonymousType :
	arrayType | pointerType | procedureType
	;

// production #17
enumerationType :
	'(' ( ( '+' namedType ) | ident ) ( ',' ( ( '+' namedType ) | ident ) )* ')'
	;

// production #18
arrayType :
	( ARRAY arrayIndex ( ',' arrayIndex )* | ASSOCIATIVE ARRAY )
	OF ( namedType | pointerType | procedureType )
	;

// alias
arrayIndex : ordinalConstExpression ;

// alias
ordinalConstExpression : constExpression ;

// production #19
recordType :
	RECORD ( '(' baseType ')' )? fieldListSequence? END
	;

// alias
baseType : ident ;

// production #20
fieldListSequence :
	fieldList ( ';' fieldList )*
	;

// production #21
fieldList :
	identList ':'
	( namedType | arrayType | pointerType | procedureType )
	;

// production #22
classType : /* extension */
	'<*QUALIFIED*>'? CLASS '(' superClass ( ',' adoptedProtocols )? ')'
	( ( PUBLIC | MODULE | PROTECTED | PRIVATE {})?
	fieldListSequence )* 
	END
	;

// alias
superClass : qualident ;

// production #23
setType :	
	SET OF ( namedEnumType | '(' identList ')' )
	;

// alias
namedEnumType : namedType ;

// production #24
pointerType :
	POINTER TO CONST? namedType
	;

// production #25
procedureType :
	PROCEDURE
	( '(' formalTypeList ')' )?
	( ':' returnedType )?
	;

// production #26
formalTypeList :
	attributedFormalType ( ',' attributedFormalType )*
	;

// production #27
attributedFormalType :
	( CONST | VAR {})? formalType	
	;

// production #28
formalType :
	( ARRAY OF )? namedType
	;

// alias
returnedType : namedType ;

// *** Variable Declarations ***

// production #30
variableDeclaration :
	ident ( '[' machineAddress ']' | ',' identList )?
	':' ( namedType | anonymousType )
	;

// alias
machineAddress : constExpression ;

// *** Procedure Declarations ***

// production #31
procedureDeclaration :
	procedureHeader ';' block ident
	;

// production #32
procedureHeader :
	PROCEDURE
	( '[' ( bindableOperator | ident ) ']' )?
	( '(' ident ':' receiverType ')' )?
	ident ( '(' formalParamList ')' )? ( ':' returnedType )?
	;

// alias
receiverType : ident ;

// production #33
formalParamList :
	formalParams ( ';' formalParams )*
	;

// production #34
formalParams :
	simpleFormalParams | variadicFormalParams
    ;

// production #35
simpleFormalParams :
	( CONST | VAR {})? identList ':' formalType
	;

// production #36
variadicFormalParams :
	VARIADIC ( variadicCounter | '[' variadicTerminator ']' )? OF
	( ( CONST | VAR {})? formalType |
	  '(' simpleFormalParams ( ';' simpleFormalParams )* ')' )
	;

// alias
variadicCounter : ident ;

// alias
variadicTerminator : constExpression ;

// *** Method Declarations ***

// production #37
methodDeclaration : /* extension */
	methodHeader ';' block ident
	;

// production #38
methodHeader : /* extension */
	CLASS? METHOD
	'(' ident ':' ( receiverClass | '*' ) ')'
	( ident | methodArg ) methodArg*
	( ':' returnedType )?
	;

// alias
receiverClass : qualident ;

// production #39
methodArg : /* extension */
	colonIdent '(' ( CONST | VAR {})? ident ':' formalType ')'
	;

// *** Statements ***

// production #40
statement :
	( assignmentOrProcedureCall |
	  methodInvocation | /* extension */
	  ifStatement |
	  caseStatement |
	  whileStatement |
	  repeatStatement |
	  loopStatement |
	  forStatement |
	  tryStatement | /* extension */
	  criticalStatement | /* extension */
	  RETURN expression? |
	  EXIT )?
	;

// production #41
statementSequence :
	statement ( ';' statement )*
	;

// production #42
methodInvocation : /* extension */
	'[' receiver message ']'
	;

// production #43
receiver : /* extension */
	ident | methodInvocation
	;

// production #44
message : /* extension */
	ident ( colonIdent expression )* |
	( colonIdent expression )+
	;

// production #45
assignmentOrProcedureCall :
	designator ( ':=' expression | '++' | '--' | actualParameters )?
	;

// production #46
ifStatement :
	IF expression THEN statementSequence
	( ELSIF expression THEN statementSequence )*
	( ELSE statementSequence )?
	END
	;

// production #47
caseStatement :
	CASE expression OF case ( '|' case )*
	( ELSE statementSequence )?
	END
	;

// production #48
case :
	caseLabelList ':' statementSequence
	;

// production #49
caseLabelList :
	caseLabels ( ',' caseLabels )*
	;

// production #50
caseLabels :
	constExpression ( '..' constExpression )?
	;

// production #51
whileStatement :
	WHILE expression DO statementSequence END
	;

// production #52
repeatStatement :
	REPEAT statementSequence UNTIL expression
	;

// production #53
loopStatement :
	LOOP statementSequence END
	;

// production #54
forStatement :
	FOR ident
	( IN expression |
	  ':' namedType ':=' expression TO expression ( BY constExpression )? )
	DO statementSequence END
	;

// production #55
tryStatement : /* extension */
	TRY statementSequence
	ON ident /* NSException */ DO statementSequence
	CONTINUE statementSequence
	END
	;

// production #56
criticalStatement : /* extension */
	CRITICAL '(' classInstance ')'
	statementSequence
	END
	;

// alias
classInstance : qualident ;

// *** Expressions ***

// production #57
constExpression :
	simpleConstExpr ( relation simpleConstExpr )?
	;

// production #58
relation :
	'=' | '#' | '<' | '<=' | '>' | '>=' | IN
	{} // make ANTLRworks display separate branches
	;

// production #59
simpleConstExpr :
	( '+' | '-' {})? constTerm ( addOperator constTerm )*
	;

// production #60
addOperator :
	'+' | '-' | OR
	{} // make ANTLRworks display separate branches
	;

// production #61
constTerm :
	constFactor ( mulOperator constFactor )*
	;

// production #62
mulOperator :
	'*' | '/' | DIV | MOD | AND | '&'
	{} // make ANTLRworks display separate branches
	;

// production #63
constFactor :
	( number |
	  string |
	  constQualident |
	  constStructuredValue |
	  '(' constExpression ')' ) ( '::' namedType )? |
	( NOT | '~' {}) constFactor
	;

// production #64
designator :
	qualident designatorTail?
	;

// production #65
designatorTail :
	( ( '[' expressionList ']' | '^' ) ( '.' ident )* )+
	;

// production #66
expressionList :
	expression ( ',' expression )*
	;

// production #67
expression :
	simpleExpression ( relation simpleExpression )?
	;

// production #68
simpleExpression :
	( '+' | '-' {})? term ( addOperator term )*
	;

// production #69
term :
	factor ( mulOperator factor )*
	;

// production #70
factor :
	( number |
	  string |
	  structuredValue
	  designatorOrProcedureCall |
	  '(' expression ')' ) ( '::' namedType )? |
	( NOT | '~' {}) factor |
	methodInvocation /* extension */
	;

// production #71
designatorOrProcedureCall :
	qualident designatorTail? actualParameters?
	;

// production #72
actualParameters :
	'(' expressionList? ')'
	;

// *** Value Constructors ***

// production #73
constStructuredValue :
	'{' ( constValueComponent ( ',' constValueComponent )* )? '}'	
	;

// production #74
constValueComponent :
	constExpression ( ( BY | '..' {}) constExpression  )?
	;

// production #75
structuredValue :
	'{' ( valueComponent ( ',' valueComponent )* )? '}'	
	;

// production #76
valueComponent :
	expression ( ( BY | '..' {}) constExpression )?
	;

// *** Identifiers ***

// production #77
qualident :
	ident ( '.' ident )*
	;

// production #78
identList :
	ident ( ',' ident )*
	;

// alias
ident :	IDENT ;

// alias
constQualident : qualident ; // no type and no variable identifiers

// alias
colonIdent : COLON_IDENT ;

// *** Literals ***

// alias
number : NUMBER ;

// alias
string : STRING ;


// ---------------------------------------------------------------------------
// P R A G M A   S Y M B O L S
// ---------------------------------------------------------------------------
// 5 productions, 2 aliases

// *** Pragmas ***

// production #1
pragma :
	'<*'
	( conditionalPragma | compileTimeMessagePragma | codeGenerationPragma |
	  implementationDefinedPragma )
	'*>'
	;

// production #2
conditionalPragma :
	( IF | ELSIF {}) constExpression | ELSE | ENDIF
	;

// production #3
compileTimeMessagePragma :
	( INFO | WARN | ERROR | FATAL {}) compileTimeMessage
	;

// production #4
codeGenerationPragma :
	ALIGN '=' constExpression | FOREIGN ( '=' string )? | MAKE '=' string |
	INLINE | NOINLINE | VOLATILE | FRAMEWORK | IBACTION | IBOUTLET | QUALIFIED
	;

// production #5
implementationDefinedPragma :
	pragmaName ( '+' | '-' | '=' ( ident | number ) )?
	;

// alias
compileTimeMessage : string ;

// alias
pragmaName : ident ; // lowercase or camelcase only


// ---------------------------------------------------------------------------
// T E R M I N A L   S Y M B O L S
// ---------------------------------------------------------------------------
// 10 productions

// production #1
IDENT :
	( '_' | '$' | LETTER ) ( '_' | '$' | LETTER | DIGIT )*
	;

// production #2
COLON_IDENT : /* extension */
	IDENT ':'
	;

// production #3
NUMBER :
	// Decimal integer
	DIGIT+ |
	
	// Binary integer
	BINARY_DIGIT+ 'B' |
	
	// Sedecimal integer
	DIGIT SEDECIMAL_DIGIT* ( 'C' | 'H' {}) |
	
	// Real number
	DIGIT+ '.' DIGIT+ ( 'E' ( '+' | '-' {})? DIGIT+ )?
	;

// production #4
STRING :
//  Proper EBNF for STRING
    SINGLE_QUOTE ( CHARACTER | DOUBLE_QUOTE )* SINGLE_QUOTE |
    DOUBLE_QUOTE ( CHARACTER | SINGLE_QUOTE )* DOUBLE_QUOTE
//
//  Alternative EBNF to make ANTLRworks display the diagram properly
//	SINGLE_QUOTE ( CHARACTER | DOUBLE_QUOTE | )+ SINGLE_QUOTE |
//	DOUBLE_QUOTE ( CHARACTER | SINGLE_QUOTE | )+ DOUBLE_QUOTE
	;

// production #5
fragment
LETTER :
	'A' .. 'Z' | 'a' .. 'z'
	{} // make ANTLRworks display separate branches
	;

// production #6
fragment
DIGIT :
	BINARY_DIGIT | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
	{} // make ANTLRworks display separate branches
	;

// production #7
fragment
BINARY_DIGIT :
	'0' | '1'
	{} // make ANTLRworks display separate branches
	;

// production #8
fragment
SEDECIMAL_DIGIT :
	DIGIT | 'A' | 'B' | 'C' | 'D' | 'E' | 'F'
	{} // make ANTLRworks display separate branches
	;

// production #9
fragment
CHARACTER :
	DIGIT | LETTER | 	
	// any printable characters other than single and double quote
	' ' | '!' | '#' | '$' | '%' | '&' | '(' | ')' | '*' | '+' |
	',' | '-' | '.' | ':' | ';' | '<' | '=' | '>' | '?' | '@' |
	'[' | ']' | '^' | '_' | '`' | '{' | '|' | '}' | '~' |
	ESCAPE_SEQUENCE 
	;

// production #10
fragment
ESCAPE_SEQUENCE :
	BACKSLASH
	( '0' | 'n' | 'r' | 't' | BACKSLASH | SINGLE_QUOTE | DOUBLE_QUOTE {})
	;


// ---------------------------------------------------------------------------
// I G N O R E   S Y M B O L S
// ---------------------------------------------------------------------------
// 6 productions

// *** Whitespace ***

// production #1
WHITESPACE :
	' ' | ASCII_TAB
	{} // make ANTLRworks display separate branches
	{ $channel = HIDDEN; } // ignore
	;

// *** Comments ***

// production #2
COMMENT :
	NESTABLE_COMMENT | NON_NESTABLE_COMMENT | SINGLE_LINE_COMMENT
	{ $channel = HIDDEN; } // ignore
	;

// production #3
fragment
NESTABLE_COMMENT :
	'(*'
	( options { greedy=false; }: . )* // anything other than '(*' or '*)'
	NESTABLE_COMMENT*
	'*)'
	;	

// production #4
fragment
NON_NESTABLE_COMMENT :
	'/*'
	( options { greedy=false; }: . )* // anything other than '*/'
	'*/'
	;

// production #5
fragment
SINGLE_LINE_COMMENT :
	'//'
	( options { greedy=false; }: . )* // anything other than EOL
	END_OF_LINE
	;

// production #6
fragment
END_OF_LINE :
	ASCII_LF ASCII_CR? | ASCII_CR ASCII_LF?
	;

// END OF FILE
