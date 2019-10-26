module grammar.declaration;

import compiler.source;
import compiler.state;

import grammar.literal;

/*
 * compilation module =
 *  program module | definition module | implementation module ;
 */
public void compilationModule(Source source, State state) in {
    assert(source);
    assert(state);
} body {
    source.pushBookmark();
    programModule(source, state);
    if (state.success) {
        return;
    } else {
        source.popBookmark();
    }

    source.pushBookmark();
    definitionModule(source, state);
    if (state.success) {
        return;
    } else {
        source.popBookmark();
    }

    source.pushBookmark();
    implementationModule(source, state);
    if (state.success) {
        return;
    } else {
        source.popBookmark();
    }

    import std.stdio; //todo replace this error reporting with something better
    stderr.writeln("Expected MODULE, DEFINITION, or IMPLEMENTATION, saw:");
    source.writeErrorContext(stderr);
}

/**
 * program module =
 *  "MODULE", module identifier, [interrupt protection], semicolon,
 *  import lists,
 *  module block, module identifier, period ;
 */
private void programModule(Source source, State state) in {
    assert(source);
    assert(state);
} body {
    state.success = false;

    consumeWhitespace(source);
    if (!consumeLiteral("MODULE", source)) return;

    if (!consumeWhitespace(source)) return;
    if (!moduleIdentifier(source)) return;

    //todo interrupt protection

    if (!consumeLiteral(";", source)) return;
    if (!importLists(source)) return;

    //todo module block
    //todo module identifier
    //todo period
    state.success = true;
}

/**
 * module identifier =
 *  identifier ;
 */
private bool moduleIdentifier(Source source) in {
    assert(source);
} body {
    return consumeIdentifier(source);
}

/**
 * definition module =
 *  "DEFINITION", "MODULE", module identifier, semicolon,
 *  import lists, definitions,
 *  "END", module identifier, period ;
 */
private void definitionModule(Source source, State state) in {
    assert(source);
    assert(state);
} body {
    state.success = false;
    //todo figure out what to do about the preprocessor that shows up frequently in definition modules

    consumeWhitespace(source);
    if (!consumeLiteral("DEFINITION", source)) return;

    if (!consumeWhitespace(source)) return;
    if (!consumeLiteral("MODULE", source)) return;

    if (!consumeWhitespace(source)) return;
    if (!moduleIdentifier(source)) return;

    if (!consumeLiteral(";", source)) return;
    if (!importLists(source)) return;

    //todo definitions
    //todo END
    //todo module identifier
    //todo period
    state.success = true;
}

/**
 * implementation module =
 *  "IMPLEMENTATION", "MODULE", module identifier,
 *  [interrupt protection], semicolon,
 *  import lists,
 *  module block, module identifier, period ;
 */
private void implementationModule(Source source, State state) in {
    assert(source);
    assert(state);
} body {
    state.success = false;

    consumeWhitespace(source);
    if (!consumeLiteral("IMPLEMENTATION", source)) return;

    if (!consumeWhitespace(source)) return;
    if (!consumeLiteral("MODULE", source)) return;

    if (!consumeWhitespace(source)) return;
    if (!moduleIdentifier(source)) return;

    //todo finish interrupt protection

    if (!consumeLiteral(";", source)) return;
    if (!importLists(source)) return;

    //todo module block
    //todo module identifier
    //todo period
    state.success = true;
}

/**
 * interrupt protection =
 *  left bracket, protection expression, right bracket ;
 */

/**
 * protection expression =
 *  constant expression ;
 */

/**
 * module block =
 *  declarations, [module body], "END" ;
 */

/**
 * module body =
 *  initialization body, [finalization body] ;
 */

/**
 * initialization body =
 *  "BEGIN", block body ;
 */

/**
 * finalization body =
 *  "FINALLY", block body ;
 */

/**
 * block body =
 *  normal part, ["EXCEPT", exceptional part ] ;
 */

/**
 * normal part =
 *  statement sequence ;
 */

/**
 * exceptional part =
 *  statement sequence ;
 */

/**
 * import lists =
 *  { import list } ;
 */
private bool importLists(Source source) in {
    assert(source);
} body {
    while (importList(source)) {
        // empty
    }
    return true;
}

/**
 * import list =
 *  simple import | unqualified import ;
 */
private bool importList(Source source) in {
    assert(source);
} body {
    source.pushBookmark();
    if (simpleImport(source)) {
        source.discardBookmark();
        return true;
    }
    source.popBookmark();

    source.pushBookmark();
    if (unqualifiedImport(source)) {
        source.discardBookmark();
        return true;
    }
    source.popBookmark();

    return false;
}

/**
 * simple import =
 *  "IMPORT", identifier list, semicolon ;
 */
private bool simpleImport(Source source) in {
    assert(source);
} body {
    consumeWhitespace(source);
    if (!consumeLiteral("IMPORT", source)) return false;

    if (!identifierList(source)) return false;

    consumeWhitespace(source);
    return consumeLiteral(";", source);
}

/**
 * unqualified import =
 *  "FROM", module identifier, "IMPORT", identifier list, semicolon ;
 */
private bool unqualifiedImport(Source source) in {
    assert(source);
} body {
    consumeWhitespace(source);
    if (!consumeLiteral("FROM", source)) return false;

    if (!consumeWhitespace(source)) return false;
    if (!moduleIdentifier(source)) return false;

    if (!consumeWhitespace(source)) return false;
    if (!consumeLiteral("IMPORT", source)) return false;

    if (!identifierList(source)) return false;

    consumeWhitespace(source);
    return consumeLiteral(";", source);
}

/**
 * export list =
 *  unqualified export | qualified export ;
 */

/**
 * unqualified export =
 *  "EXPORT", identifier list, semicolon ;
 */

/**
 * qualified export =
 *  "EXPORT", "QUALIFIED", identifier list, semicolon ;
 */

/**
 * qualified identifier =
 *  { qualifying identifier, period }, identifier ;
 */

/**
 * qualifying identifier =
 *  module identifier ;
 */

/**
 * definitions =
 *  { definition } ;
 */

/**
 * definition =
 *  "CONST", { constant declaration, semicolon } |
 *  "TYPE", { type definition, semicolon } |
 *  "VAR", { variable declaration, semicolon } |
 *  procedure heading, semicolon ;
 */

/**
 * procedure heading =
 *  proper procedure heading | function procedure heading ;
 */

/**
 * type definition =
 *  type declaration | opaque type definition ;
 */

/**
 * opaque type definition =
 *  identifier ;
 */

/**
 * declarations =
 *  { declaration } ;
 */

/**
 * declaration =
 *  "CONST", { constant declaration, semicolon }  |
 *  "TYPE", { type declaration, semicolon }  |
 *  "VAR", { variable declaration, semicolon }  |
 *  procedure declaration, semicolon  |
 *  local module declaration, semicolon ;
 */

/**
 * constant declaration =
 *  identifier, equals, constant expression ;
 */

/**
 * type declaration =
 *  identifier, equals, type denoter ;
 */

/**
 * variable declaration =
 *  variable identifier list, colon, type denoter ;
 */

/**
 * variable identifier list =
 *  identifier, [ machine address], { comma, identifier, [machine address] } ;
 */

/**
 * machine address =
 *  left bracket, value of address type, right bracket ;
 */

/**
 * value of address type =
 *  constant expression ;
 */

/**
 * procedure declaration =
 *  proper procedure declaration | function procedure declaration ;
 */

/**
 * proper procedure declaration =
 *  proper procedure heading, semicolon,
 *  ( proper procedure block, procedure identifier | "FORWARD" ) ;
 */

/**
 * procedure identifier =
 *  identifier ;
 */

/**
 * proper procedure heading =
 *  "PROCEDURE", procedure identifier, [formal parameters] ;
 */

/**
 * formal parameters =
 *  left parenthesis, [formal parameter list], right parenthesis ;
 */

/**
 * formal parameter list =
 *  formal parameter, { semicolon, formal parameter } ;
 */

/**
 * proper procedure block =
 *  declarations, [procedure body], "END" ;
 */

/**
 * procedure body =
 *  "BEGIN", block body ;
 */

/**
 * function procedure declaration =
 *  function procedure heading, semicolon,
 *  ( function procedure block, procedure identifier | "FORWARD" ) ;
 */

/**
 * function procedure heading =
 *  "PROCEDURE", procedure identifier, formal parameters,
 *  colon, function result type ;
 */

/**
 * function result type =
 *  type identifier ;
 */

/**
 * function procedure block =
 *  declarations, function body, "END" ;
 */

/**
 * function body =
 *  "BEGIN", block body ;
 */

/**
 * formal parameter =
 *  value parameter specification | variable parameter specification ;
 */

/**
 * value parameter specification =
 *  identifier list, colon, formal type ;
 */

/**
 * variable parameter specification =
 *  "VAR", identifier list, colon, formal type ;
 */

/**
 * local module declaration =
 *  "MODULE", module identifier, [interrupt protection], semicolon,
 *  import lists,
 *  [export list],
 *  module block, module identifier ;
 */

/**
 * type denoter =
 *  type identifier | new type ;
 */

/**
 * ordinal type denoter =
 *  ordinal type identifier | new ordinal type ;
 */

/**
 * type identifier =
 *  qualified identifier ;
 */

/**
 * ordinal type identifier =
 *  type identifier ;
 */

/**
 * new type =
 *  new ordinal type |
 *  set type  |
 *  packedset type  |
 *  pointer type  |
 *  procedure type  |
 *  array type  |
 *  record type ;
 */

/**
 * new ordinal type =
 *  enumeration type | subrange type ;
 */

/**
 * enumeration type =
 *  left parenthesis, identifier list, right parenthesis ;
 */

/**
 * identifier list =
 *  identifier, { comma, identifier } ;
 */
private bool identifierList(Source source) in {
    assert(source);
} body {
    consumeWhitespace(source);
    if (!consumeIdentifier(source)) return false;

    while (true) {
        source.pushBookmark();

        consumeWhitespace(source);
        if (!consumeLiteral(",", source)) {
            source.popBookmark();
            break;
        }

        consumeWhitespace(source);
        if (!consumeIdentifier(source)) {
            source.popBookmark();
            break;
        }

        source.discardBookmark();
    }

    return true;
}

/**
 * subrange type =
 *  [range type], left bracket, constant expression, ellipsis,
 *  constant expression, right bracket ;
 */

/**
 * range type =
 *  ordinal type identifier ;
 */

/**
 * set type =
 *  "SET", "OF", base type ;
 */

/**
 * base type =
 *  ordinal type denoter ;
 */

/**
 * packedset type =
 *  "PACKEDSET", "OF", base type ;
 */

/**
 * pointer type =
 *  "POINTER", "TO", bound type ;
 */

/**
 * bound type =
 *  type denoter ;
 */

/**
 * procedure type =
 *  proper procedure type | function procedure type ;
 */

/**
 * proper procedure type =
 *  "PROCEDURE",
 *  [left parenthesis, [formal parameter type list], right parenthesis] ;
 */

/**
 * function procedure type =
 *  "PROCEDURE", left parenthesis, [formal parameter type list],
 *  right parenthesis,  colon, function result type ;
 */

/**
 * formal parameter type list =
 *  formal parameter type, { comma, formal parameter type } ;
 */

/**
 * formal parameter type =
 *  variable formal type | value formal type ;
 */

/**
 * variable formal type =
 *  "VAR", formal type ;
 */

/**
 * value formal type =
 *  formal type ;
 */

/**
 * formal type =
 *  type identifier | open array formal type ;
 */

/**
 * open array formal type =
 *  "ARRAY", "OF", open array component type ;
 */

/**
 * open array component type =
 *  formal type ;
 */

/**
 * array type =
 *  "ARRAY", index type, { comma, index type }, "OF", component type ;
 */

/**
 * index type =
 *  ordinal type denoter ;
 */

/**
 * component type =
 *  type denoter ;
 */

/**
 * record type =
 *  "RECORD", field list, "END" ;
 */

/**
 * field list =
 *  fields, { semicolon, fields } ;
 */

/**
 * fields =
 *  [fixed fields | variant fields] ;
 */

/**
 * fixed fields =
 *  identifier list, colon, field type ;
 */

/**
 * field type =
 *  type denoter ;
 */

/**
 * variant fields =
 *  "CASE", tag field, "OF", variant list, "END" ;
 */

/**
 * tag field =
 *  [tag identifier], colon, tag type ;
 */

/**
 * tag identifier =
 *  identifier ;
 */

/**
 * tag type =
 *  ordinal type identifier ;
 */

/**
 * variant list =
 *  variant, { case separator, variant },
 *  [variant else part] ;
 */

/**
 * variant else part =
 *  "ELSE", field list ;
 */

/**
 * variant =
 *  [variant label list, colon, field list] ;
 */

/**
 * variant label list =
 *  variant label, { comma, variant label } ;
 */

/**
 * variant label =
 *  constant expression, [ellipsis, constant expression] ;
 */
