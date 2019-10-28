module compiler.util;

import std.stdio;

import compiler.source;

/**
 * Diagnostic to give context where in the source the parser has advanced to
 */
public void debugWrite(string file = __FILE__, size_t line = __LINE__)(Source source, string message = "Made it!") nothrow {
    try {
        stderr.writeln("---------------------------------------");
        stderr.writefln("[%s:%d] %s", file, line, message);
        source.writeErrorContext(stderr);
    } catch (Exception e) {
        assert(false, e.message);
    }
}
