module grammar.statement;

import compiler.source;

/**
 * statement =
 *  empty statement |
 *  assignment statement |
 *  procedure call |
 *  return statement |
 *  retry statement |
 *  with statement |
 *  if statement |
 *  case statement |
 *  while statement |
 *  repeat statement |
 *  loop statement |
 *  exit statement |
 *  for statement ;
 */

/**
 * statement sequence =
 *  statement, { semicolon, statement } ;
 */

/**
 * empty statement =
 *  ;
 */
private bool emptyStatement(Source source) {
    return true;
}

/**
 * assignment statement =
 *  variable designator, assignment operator, expression ;
 */

/**
 * procedure call =
 *  procedure designator, [actual parameters] ;
 */

/**
 * procedure designator =
 *  value designator ;
 */

/**
 * actual parameters =
 *  left parenthesis, [actual parameter list], right parenthesis ;
 */

/**
 * actual parameter list =
 *  actual parameter, { comma, actual parameter } ;
 */

/**
 * actual parameter =
 *  variable designator | expression | type parameter ;
 */

/**
 * type parameter =
 *  type identifier ;
 */

/**
 * return statement =
 *  simple return statement | function return statement ;
 */

/**
 * simple return statement =
 *  "RETURN" ;
 */

/**
 * function return statement =
 *  "RETURN", expression ;
 */

/**
 * retry statement =
 *  "RETRY" ;
 */

/**
 * with statement =
 *  "WITH", record designator, "DO", statement sequence, "END" ;
 */

/**
 * record designator =
 *  variable designator | value designator ;
 */

/**
 * if statement =
 *  guarded statements, [if else part], "END" ;
 */

/**
 * guarded statements =
 *  "IF", boolean expression, "THEN", statement sequence,
 *  { "ELSIF", boolean expression, "THEN", statement sequence } ;
 */

/**
 * if else part =
 *  "ELSE", statement sequence ;
 */

/**
 * case statement =
 *  "CASE", case selector, "OF", case list, "END" ;
 */

/**
 * case selector =
 *  ordinal expression ;
 */

/**
 * case list =
 *  case alternative, { case separator, case alternative }, [case else part] ;
 */

/**
 * case else part =
 *  "ELSE", statement sequence ;
 */

/**
 * case alternative =
 *  [case label list, colon, statement sequence] ;
 */

/**
 * case label list =
 *  case label, { comma, case label } ;
 */

/**
 * case label =
 *  constant expression, [ellipsis, constant expression] ;
 */

/**
 * while statement =
 *  "WHILE", boolean expression, "DO", statement sequence, "END" ;
 */

/**
 * repeat statement =
 *  "REPEAT", statement sequence, "UNTIL", boolean expression ;
 */

/**
 * loop statement =
 *  "LOOP", statement sequence, "END" ;
 */

/**
 * exit statement =
 *  "EXIT" ;
 */

/**
 * for statement =
 *  "FOR", control variable identifier, assignment operator, initial value,
 *  "TO", final value,
 *  ["BY", step size],
 *  "DO",
 *  statement sequence, "END" ;
 */

/**
 * control variable identifier =
 *  identifier ;
 */

/**
 * initial value =
 *  ordinal expression ;
 */

/**
 * final value =
 *  ordinal expression ;
 */

/**
 * step size =
 *  constant expression ;
 */

/**
 * variable designator =
 *  entire designator |
 *  indexed designator |
 *  selected designator |
 *  dereferenced designator ;
 */

/**
 * entire designator =
 *  qualified identifier ;
 */

/**
 * indexed designator =
 *  array variable designator,
 *  left bracket, index expression, { comma, index expression },
 *  right bracket ;
 */

/**
 * array variable designator =
 *  variable designator ;
 */

/**
 * selected designator =
 *  record variable designator, period, field identifier ;
 */

/**
 * record variable designator =
 *  variable designator ;
 */

/**
 * field identifier =
 *  identifier ;
 */

/**
 * dereferenced designator =
 *  pointer variable designator, dereferencing operator ;
 */

/**
 * pointer variable designator =
 *  variable designator ;
 */
