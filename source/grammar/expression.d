module grammar.expression;

/**
 * boolean expression =
 *  expression ;
 */

/**
 * index expression =
 *  ordinal expression ;
 */

/**
 * expression =
 *  simple expression, [relational operator, simple expression] ;
 */

/**
 * simple expression =
 *  [sign], term, { term operator, term } ;
 */

/**
 * term =
 *  factor, { factor operator, factor } ;
 */

/**
 * factor =
 *  left parenthesis, expression, right parenthesis |
 *  logical negation operator, factor |
 *  value designator |
 *  function call |
 *  value constructor |
 *  constant literal ;
 */

/**
 * relational operator =
 *  equals operator |
 *  inequality operator |
 *  less than operator |
 *  greater than operator |
 *  less than or equal operator |
 *  subset operator |
 *  greater than  or equal operator |
 *  superset operator |
 *  set membership operator ;
 */

/**
 * term operator =
 *  plus operator |
 *  set union operator |
 *  minus operator |
 *  set difference operator |
 *  logical disjunction operator |
 *  string catenate symbol ;
 */

/**
 * factor operator =
 *  multiplication operator |
 *  set intersection operator |
 *  division operator |
 *  symmetric set difference operator |
 *  rem operator |
 *  div operator |
 *  mod operator |
 *  logical conjunction operator ;
 */

/**
 * value designator =
 *  entire value |
 *  indexed value |
 *  selected value |
 *  dereferenced value ;
 */

/**
 * entire value =
 *  qualified identifier ;
 */

/**
 * indexed value =
 *  array value, left bracket,
 *  index expression, { comma, index expression },
 *  right bracket ;
 */

/**
 * array value =
 *  value designator ;
 */

/**
 * selected value =
 *  record value, period, field identifier ;
 */

/**
 * record value =
 *  value designator ;
 */

/**
 * dereferenced value =
 *  pointer value, dereferencing operator ;
 */

/**
 * pointer value =
 *  value designator ;
 */

/**
 * function call =
 *  function designator, actual parameters ;
 */

/**
 * function designator =
 *  value designator ;
 */

/**
 * value constructor =
 *  array constructor | record constructor | set constructor ;
 */

/**
 * array constructor =
 *  array type identifier, array constructed value ;
 */

/**
 * array type identifier =
 *  type identifier ;
 */

/**
 * array constructed value =
 *  left brace, repeated structure component,
 *  { comma, repeated structure component },
 *  right brace ;
 */

/**
 * repeated structure component =
 *  structure component, ["BY", repetition factor] ;
 */

/**
 * repetition factor =
 *  constant expression ;
 */

/**
 * structure component =
 *  expression |
 *  array constructed value |
 *  record constructed value |
 *  set constructed value ;
 */

/**
 * record constructor =
 *  record type identifier, record constructed value ;
 */

/**
 * record type identifier =
 *  type identifier ;
 */

/**
 * record constructed value =
 *  left brace,
 *  [structure component, { comma, structure component }],
 *  right brace ;
 */

/**
 * set constructor =
 *  set type identifier, set constructed value ;
 */

/**
 * set type identifier =
 *  type identifier ;
 */

/**
 * set constructed value =
 *  left brace, [member, { comma, member }], right brace ;
 */

/**
 * member =
 *  interval |  singleton ;
 */

/**
 * interval =
 *  ordinal expression, ellipsis, ordinal expression ;
 */

/**
 * singleton =
 *  ordinal expression ;
 */

/**
 * ordinal expression =
 *  expression ;
 */

/**
 * constant expression =
 *  expression ;
 */
