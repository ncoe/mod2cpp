module compiler.util;

/**
 * Diagnostic to give context where in the source the parser has advanced to
 */
public void debugWrite(string file = __FILE__, size_t line = __LINE__)(Source source, string message = "Made it!") {
    stderr.writeln("---------------------------------------");
    stderr.writefln("[%s:%d] %s", file, line, message);
    source.writeErrorContext(stderr);
}
