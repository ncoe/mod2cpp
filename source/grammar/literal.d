module grammar.literal;

import compiler.source;

/**
 * constant literal =
 *  whole number literal |
 *  real literal |
 *  string literal ;
 */
public bool constantLiteral(Source source) {
    assert(false);
}

private bool isWhitespace(ubyte u) {
    return ' ' == u || '\t' == u || '\r' == u || '\n' == u;
}

public bool consumeWhitespace(Source source) in {
    assert(source);
} body {
    bool result = false;
    while (isWhitespace(source.front)) {
        if (source.front == '\r') {
            // maybe mac line endings
            source.popFront;
            if (source.front == '\n') {
                // windows line endings
                source.popFront;
            }
            source.updateLine();
        } else if (source.front == '\n') {
            // unix line endings
            source.popFront;
            source.updateLine();
        } else {
            // no line ending detected
            source.popFront;
        }

        result = true;
    }
    return result;
}

public bool consumeLiteral(string literal, Source source) in {
    assert(source);
} body {
    auto end = source.offset + literal.length;
    if (end < source.length) {
        import std.range;
        auto actual = source.take(literal.length).array;
        return actual == literal;
    } else {
        return false;
    }
}

private bool isLetter(ubyte u) {
    return ('A' <= u && u <= 'Z') || ('a' <= u && u <= 'z');
}

private bool isNumber(ubyte u) {
    return '0' <= u && u <= '9';
}

public bool consumeIdentifier(Source source) in {
    assert(source);
} body {
    bool result = false;
    if (source.front == '*') {
        // special case for the import identifier list
        source.popFront;
        return true;
    }
    if (isLetter(source.front)) {
        result = true;
        source.popFront;
    }
    while (isLetter(source.front) || isNumber(source.front)) {
        source.popFront;
    }
    return result;
}
