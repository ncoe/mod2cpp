/* ANTLR v3 Grammar for ISO-Modula-2
 *
 * Documentation version, derived from the ISO/IEC IS 10514 base standard
 *
 * This grammar follows the  naming conventions  and structure of the concrete
 * syntax of  ISO Modula-2  as provided in the ISO/IEC IS 10514 base standard.
 * It is important to note  that the  concrete syntax in the standard has been
 * written  for the purpose of  documenting the language,  not for the purpose
 * of constructing a compiler.  Therefore,  this grammar does  not satsify the
 * constraints  for  parser  construction,  and consequently  ANTLR  will  not
 * validate the grammar in this form.  It can  however  be used for generating
 * syntax graphs using ANTLRworks,  or  as a starting point for refactoring.
 *
 * As time permits,  the author will do the necessary refactoring  to convert
 * the grammar into an equivalent LL(1) grammar, suitable for building a
 * compiler with ANTLR, which shall be published as a separate file.
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

grammar m2iso; // Modula-2 ISO/IEC IS 10514 base standard

// file version 1.00, May 16, 2009


tokens {
	
	// Reserved Words

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
	EXCEPT         = 'EXCEPT';
	EXIT           = 'EXIT';
	EXPORT         = 'EXPORT';
	FINALLY        = 'FINALLY';
	FOR            = 'FOR';
	FORWARD        = 'FORWARD';
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
	PACKEDSET      = 'PACKEDSET';
	POINTER        = 'POINTER';
	PROCEDURE      = 'PROCEDURE';
	QUALIFIED      = 'QUALIFIED';
	RECORD         = 'RECORD';
	REM            = 'REM';
	REPEAT         = 'REPEAT';
	RETRY          = 'RETRY';
	RETURN         = 'RETURN';
	SET            = 'SET';
	THEN           = 'THEN';
	TO             = 'TO';
	TYPE           = 'TYPE';
	UNTIL          = 'UNTIL';
	VAR            = 'VAR';
	WHILE          = 'WHILE';
	WITH           = 'WITH';

	// Operators
	
	ASSIGN_OP           = ':=';
	LOGICAL_AND_OP      = '&';
	LOGICAL_NOT_OP      = '~';
	EQUALS              = '=';
	NOT_EQUAL_OP        = '#';
	PASCAL_NOT_EQUAL_OP = '<>';
	GREATER_OP          = '>';
	GREATER_OR_EQUAL_OP = '>=';
	LESS_OP             = '<';
	LESS_OR_EQUAL_OP    = '<=';
	PLUS_OP             = '+';
	MINUS_OP            = '-';
	MULTIPLY_OP	        = '*';
	DIVIDE_OP           = '/';
	POINTER_OP          = '^';
	
	// Punctuation
	
	PERIOD = '.';
	ELLIPSIS = '..';
}

// ---------------------------------------------------------------------------
// P A R S E R   G R A M M A R
// ---------------------------------------------------------------------------

// 1.1 Programs and Compilation Modules

compilation_module :
	program_module | definition_module | implementation_module
	;

// 1.2 Program Modules

program_module :
	'MODULE' module_identifier ( protection )? ';'
	import_lists module_block module_identifier '.'
	;

module_identifier :
	identifier
	;

protection :
	'[' protection_expression ']'
	;

protection_expression :
	constant_expression
	;

// 1.3 Definition Module

definition_module :
	'DEFINITION' 'MODULE' module_identifier ';'
	import_lists definitions 'END' module_identifier '.'
	;

// 1.4 Implementation Module

implementation_module :
	'IMPLEMENTATION' 'MODULE' module_identifier ( protection )? ';'
	import_lists module_block module_identifier '.'
	;

// 1.5 Import Lists

import_lists :
	( import_list )*
	;

// 1.5.1 Import List

import_list :
	simple_import | unqualified_import
	;

// 1.5.2 Simple Import

simple_import :
	'IMPORT' identifier_list ';'
	;

// 1.5.3 Unqualified Import

unqualified_import :
	'FROM' module_identifier 'IMPORT' identifier_list ';'
	;

// 1.6 Export Lists

export_list :
	unqualified_export | qualified_export
	;

// 1.6.1 Unqualified Export

unqualified_export :
	'EXPORT' 'QUALIFIED' identifier_list ';'
	;

// 1.6.2 Qualified Export

qualified_export :
	'EXPORT' 'QUALIFIED' identifier_list ';'
	;

// 2.1 Qualified Identifiers

qualified_identifier :
	( module_identifier '.' )* identifier
	;

// 2.2 Definitions

definitions :
	( definition )*
	;

definition :
	'CONST' ( constant_declaration ';' )* |
	'TYPE' ( type_declaration ';' )* |
	'VAR' ( variable_declaration ';' )* |
	procedure_heading ';'
	;

procedure_heading :
	proper_procedure_heading | function_procedure_heading
	;

// 2.2.1 Type Definitions

type_definition :
	type_declaration | opaque_type_definition
	;

opaque_type_definition :
	identifier
	;

// 2.2.2 Proper Procedure Heading

proper_procedure_heading :
	'PROCEDURE' procedure_identifier ( formal_parameters )? ';'
	;

formal_parameters :
	'(' ( formal_parameter_list )? ')'
	;

formal_parameter_list :
	formal_parameter ( ';' formal_parameter )*
	;

// 2.2.3 Function Procedure Heading

function_procedure_heading :
	'PROCEDURE' procedure_identifier ( formal_parameters )?
	':' function_result_type ';'
	;

function_result_type :
	type_identifier;

// 2.2.4 Formal Parameter

formal_parameter :
	value_parameter_specification | variable_parameter_specification
	;

// 2.2.4.1 Value Parameter

value_parameter_specification :
	identifier_list ':' formal_type
	;

// 2.2.4.2 Variable Parameter

variable_parameter_specification :
	'VAR' identifier_list ':' formal_type
	;

// 2.3 Declarations

declarations :
	( declaration )*
	;

declaration :
	'CONST' ( constant_declaration ';' )* |
	'TYPE' ( type_declaration ';' )* |
	'VAR' ( variable_declaration ';' )* |
	procedure_declaration ';' |
	local_module_declaration ';'	
	;

// 2.4 Constant Declaration

constant_declaration :
	identifier '=' constant_expression
	;

// 2.5 Type Declaration

type_declaration :
	identifier '=' type_denoter
	;

// 2.6 Variable Declaration

variable_declaration :
	variable_identifier_list ':' type_denoter
	;

variable_identifier_list :
	identifier ( machine_address )? ( ',' identifier ( machine_address )? )*
	;

machine_address :
	'[' value_of_address_type ']'
	;

value_of_address_type :
	constant_expression
	;

// 2.7 Procedure Declaration

procedure_declaration :
	proper_procedure_declaration | function_procedure_declaration
	;

// 2.8 Proper Procedure Declaration

proper_procedure_declaration :
	proper_procedure_heading ';'
	( proper_procedure_block procedure_identifier | 'FORWARD' )
	;

procedure_identifier :
	identifier
	;

// 2.8.1 Function Procedure Declaration

function_procedure_declaration :
	function_procedure_heading ';'
	( function_procedure_block procedure_identifier | 'FORWARD' )
	;

// 2.9 Local Module Declaration

local_module_declaration :
	'MODULE' module_identifier ( protection )? ';'
	import_lists ( export_list )? module_block module_identifier 
	;

// 3 Types

type_denoter :
	type_identifier | new_type
	;

ordinal_type_denoter :
	ordinal_type_identifier | new_ordinal_type
	;

// 3.1 Type Identifier

type_identifier :
	qualified_identifier 
	;

ordinal_type_identifier :
	type_identifier
	;

// 3.2 New Type

new_type :
	new_ordinal_type | set_type | packedset_type | pointer_type |
	procedure_type | array_type | record_type
	;

new_ordinal_type :
	enumeration_type | subrange_type
	;

// 3.2.1 Enumeration Type

enumeration_type :
	'(' identifier_list ')'
	;

identifier_list :
	identifier ( ',' identifier )*
	;

// 3.2.2 Subrange Type

subrange_type :
	( range_type )? '[' constant_expression '..' constant_expression ']'
	;

range_type :
	ordinal_type_identifier
	;

// 3.2.3 Set Type

set_type :
	'SET' 'OF' base_type
	;

base_type :
	ordinal_type_denoter
	;

// 3.2.4 Packedset Type

packedset_type :
	'PACKEDSET' 'OF' base_type
	;

// 3.2.5 Pointer Type

pointer_type :
	'POINTER' 'TO' bound_type
	;

bound_type :
	type_denoter
	;

// 3.2.6 Procedure Type

procedure_type :
	proper_procedure_type | function_procedure_type
	;

fragment
proper_procedure_type :
	'PROCEDURE' '(' ( formal_parameter_type_list )? ')'
	;

function_procedure_type :
	'PROCEDURE' '(' ( formal_parameter_type_list )? ')'
	':' function_result_type
	;

formal_parameter_type_list :
	formal_parameter_type ( ',' formal_parameter_type )*
	;

formal_parameter_type :
	variable_formal_type | value_formal_type
	;

variable_formal_type :
	'VAR' formal_type
	;

value_formal_type :
	formal_type
	;

// 3.2.7 Formal Type

formal_type :
	type_identifier | open_array_formal_type
	;

open_array_formal_type :
	'ARRAY' 'OF' ( 'ARRAY' 'OF' )* type_identifier
	;

// 3.2.8 Array Type

array_type :
	'ARRAY' index_type ( ',' index_type )* 'OF' component_type
	;

index_type :
	ordinal_type_denoter
	;

component_type :
	type_denoter
	;

// 3.2.9 Record Type

record_type :
	'RECORD' field_list 'END'
	;

field_list :
	fields ( ';' fields )*
	;

fields :
	( fixed_fields | variant_fields )?
	;

fixed_fields :
	identifier_list ':' field_type
	;

field_type :
	type_denoter
	;

variant_fields :
	'CASE' ( tag_identifier )? ':' tag_type 'OF' variant_list 'END'
	;

tag_identifier :
	identifier
	;

tag_type :
	ordinal_type_identifier
	;

variant_list :
	variant ( '|' variant )* ( variant_else_part )?
	;

variant_else_part :
	'ELSE' field_list
	;

variant :
	( variant_label_list ':' field_list )?
	;

variant_label_list :
	variant_label ( '.' variant_label )*
	;

variant_label :
	constant_expression ( '..' constant_expression )?
	;

// 4 Blocks

// 4.1 Proper Procedure Block

proper_procedure_block :
	declarations ( procedure_body )? 'END'
	;

procedure_body :
	'BEGIN' block_body
	;

// 4.2 Function Procedure Block

function_procedure_block :
	declarations function_body 'END'
	;

function_body :
	'BEGIN' block_body
	;

// 4.3 Module Block

module_block :
	declarations ( module_body )? 'END'
	;

module_body :
	initialization_body ( finalization_body )?
	;

initialization_body :
	'BEGIN' block_body
	;

finalization_body :
	'FINALLY' block_body
	;

// 4.4 Block Bodies and Exception Handling

block_body :
	normal_part ( 'EXCEPT' exceptional_part )?
	;

normal_part :
	statement_sequence
	;

exceptional_part :
	statement_sequence
	;

// 5 Statements

statement :
	empty_statement | assignment_statement | procedure_call |
	return_statement | retry_statement | with_statement |
	if_statement | case_statement | while_statement |
	repeat_statement | loop_statement | exit_statement |
	for_statement
	;

// 5.1 Statement Sequence

statement_sequence :
	statement ( ';' statement )*
	;

// 5.2 Empty Statement

empty_statement :
	';'
	;

// 5.3 Assigmment Statement

assignment_statement :
	variable_designator ':=' expression
	;

// 5.4 Procedure Call

procedure_call :
	procedure_designator ( actual_parameters )?
	;

procedure_designator :
	value_designator
	;

// 5.5 Return Statement

return_statement :
	simple_return_statement | function_return_statement
	;

// 5.5.1 Simple Return Statement

simple_return_statement :
	'RETURN'
	;

// 5.5.3 Function Return Statement

function_return_statement :
	'RETURN' expression
	;

// 5.6 Retry Statement

retry_statement :
	'RETRY'
	;

// 5.7 With Statement

with_statement :
	'WITH' record_designator 'DO' statement_sequence 'END'
	;

record_designator :
	variable_designator | value_designator
	;

// 5.8 If Statement

if_statement :
	guarded_statements ( if_else_part )? 'END'
	;

guarded_statements :
	'IF' boolean_expression 'THEN' statement_sequence
	( 'ELSIF' boolean_expression 'THEN' statement_sequence )*
	;

if_else_part :
	'ELSE' statement_sequence
	;

boolean_expression :
	expression
	;

// 5.9 Case Statement

case_statement :
	'CASE' case_selector 'OF' case_list 'END'
	;

case_selector :
	ordinal_expression
	;

case_list :
	case_alternative ( '|' case_alternative )*
	;

case_else_part :
	'ELSE' statement_sequence
	;

// 5.9.1 Case Alternative

case_alternative :
	( case_label_list )? ':' statement_sequence
	;

case_label_list :
	case_label ( ',' case_label )*
	;

case_label :
	constant_expression ( '..' constant_expression )?
	;

// 5.10 While Statement

while_statement :
	'WHILE' boolean_expression 'DO' statement_sequence 'END'
	;

// 5.11 Repeat Statement

repeat_statement :
	'REPEAT' statement_sequence 'UNTIL' boolean_expression
	;

// 5.12 Loop Statement

loop_statement :
	'LOOP' statement_sequence 'END'
	;

// 5.13 Exit Statement

exit_statement :
	'EXIT'
	;

// 5.14 For Statement

for_statement :
	'FOR' control_variable_identifier ':=' initial_value 'TO' final_value
	( 'BY' step_size )? 'DO' statement_sequence 'END'
	;

control_variable_identifier :
	identifier
	;

initial_value :
	ordinal_expression
	;

final_value :
	ordinal_expression
	;

step_size :
	constant_expression
	;

// 6 Variable Designator

variable_designator :
	entire_designator | indexed_designator | selected_designator |
	dereferenced_designator
	;

// 6.1 Entire Designator

entire_designator :
	qualified_identifier
	;

// 6.2 Indexed Designator

indexed_designator :
	array_variable_designator '[' index_expression ( ',' index_expression )* ']'
	;

array_variable_designator :
	variable_designator
	;

index_expression :
	ordinal_expression
	;

// 6.3 Selected Designator

selected_designator :
	record_variable_designator '.' field_identifier
	;

record_variable_designator :
	variable_designator;

field_identifier :
	identifier
	;

// 6.4 Dereferenced Designator

dereferenced_designator :
	pointer_variable_designator '^'
	;

pointer_variable_designator :
	variable_designator
	;

// 7 Expressions

expression :
	simple_expression ( relational_operator simple_expression )?
	;

simple_expression :
	( '+' | '-' )? term ( term_operator term )*
	;

term :
	factor ( factor_operator factor )*
	;

factor :
	'(' expression ')' |
	'NOT' factor |
	value_designator |
	function_call |
	value_constructor |
	constant_literal
	;

ordinal_expression :
	expression
	;

// 7.1 Infix Expressions

relational_operator :
	'=' | '#' | '<' | '<=' | '>' | '>=' | 'IN' |
	;

term_operator :
	'+' | '-' | 'OR'
	;

factor_operator :
	'*' | '/' | 'REM' | 'DIV' | 'MOD' | 'AND'
	;

// 7.2 Value Designator

value_designator :
	entire_value | indexed_value | selected_value | dereferenced_value
	;

// 7.2.1 Entire Value

entire_value :
	qualified_identifier
	;

// 7.2.2 Indexed Value

indexed_value :
	array_value '[' index_expression ( ',' index_expression )* ']'
	;

array_value :
	value_designator
	;

// 7.2.3 Selected Value

selected_value :
	record_value '.' field_identifier
	;

record_value :
	value_designator
	;

// 7.2.4 Dereferenced Value

dereferenced_value :
	pointer_value '^'
	;

pointer_value :
	value_designator
	;

// 7.3 Function Call

function_call :
	function_designator actual_parameters
	;

function_designator :
	value_designator
	;

// 7.4 Value Constructors

value_constructor :
	array_constructor | record_constructor | set_constructor
	;

// 7.4.1 Array Constructor

array_constructor :
	array_type_identifier array_constructed_value
	;

array_type_identifier :
	type_identifier;

array_constructed_value :
	'{' repeated_structure_component ( ',' repeated_structure_component )* '}'
	;

repeated_structure_component :
	structure_component ( 'BY' repetition_factor )?
	;

repetition_factor :
	constant_expression
	;

structure_component :
	expression | array_constructed_value | record_constructed_value |
	set_constructed_value
	;

// 7.4.2 Record Constructor

record_constructor :
	record_type_identifier record_constructed_value
	;

record_type_identifier :
	type_identifier
	;

record_constructed_value :
	'{' ( structure_component )? ( ',' structure_component )* '}'
	;

// 7.4.3 Set Constructor

set_constructor :
	set_type_identifier set_constructed_value
	;

set_type_identifier :
	type_identifier
	;

set_constructed_value :
	'{' ( member  ( ',' member )* )? '}'
	;

member :
	interval | singleton
	;

interval :
	ordinal_expression '..' ordinal_expression
	;

singleton :
	ordinal_expression
	;

// 7.5 Constant Literal

constant_literal :
	whole_number_literal | real_literal | string_literal | pointer_literal
	;

// 7.6 Constant Expression

constant_expression :
	expression
	;

// 8 Parameter and Argument Binding

// 8.1 Actual Parameters

actual_parameters :
	'(' ( actual_parameter_list )? ')'
	;

actual_parameter_list :
	actual_parameter ( ',' actual_parameter )*
	;

actual_parameter :
	variable_designator | expression | type_parameter
	;

// 8.2 Special Parameters

// 8.2.1 Type Parameter

type_parameter :
	type_identifier
	;

// mapping of lowercase names to terminals

identifier :
	IDENTIFIER ;

whole_number_literal :
	WHOLE_NUMBER_LITERAL
	;

real_literal :
	REAL_LITERAL
	;

string_literal :
	STRING_LITERAL
	;

pointer_literal :
	POINTER_LITERAL
	;


// ---------------------------------------------------------------------------
// L E X E R   G R A M M A R
// ---------------------------------------------------------------------------


IDENTIFIER :
	LETTER ( LETTER | DIGIT )*
	;

WHOLE_NUMBER_LITERAL :
	DIGIT ( DIGIT )* ( OCTAL_DIGIT ( OCTAL_DIGIT )* ( 'B' | 'C' ) )?
	| DIGIT ( HEX_DIGIT )* 'H'
	;

REAL_LITERAL :
	DIGIT ( DIGIT )* '.' ( DIGIT )* ( SCALE_FACTOR )?
	;

STRING_LITERAL :
	'\'' ( CHARACTER )* '\'' | '"' ( CHARACTER )* '"'
	;

POINTER_LITERAL :
	;

COMMENT :
	'(*' ( : . )* ( COMMENT )* '*)'
	;

fragment
LETTER : '_' | 'A' .. 'Z' | 'a' .. 'z' ;

fragment
DIGIT :	OCTAL_DIGIT | '8' | '9' ;

fragment
OCTAL_DIGIT : '0' .. '7' ;

fragment
HEX_DIGIT : DIGIT | 'A' | 'B' | 'C' | 'D' | 'E' | 'F' ;

fragment
SCALE_FACTOR :
	'E' ( '+' | '-' )? DIGIT ( DIGIT )*
	;

fragment
CHARACTER :
	// any printable characters other than single and double quote
	~( '\u0000' .. '\u001f' | '\'' | '"' )
	;

// END OF FILE
