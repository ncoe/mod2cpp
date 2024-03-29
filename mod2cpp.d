import std.stdio;

import compiler.source;
import compiler.util;
import grammar.lex;
import grammar.program;

int main(string[] args) {
    if (args.length < 2) {
        stderr.writeln("Expected a source file to be given as an argument.");
        return 1;
    }

    auto fileName = args[1];
    stderr.writeln("Processing the source file: ", fileName);

    auto source = new Source(fileName);
    auto value = parse(source);
    return value;
}

int parse(Source source) in {
    assert(source);
} body {
    if (parseCompilationUnit(source)) {
        lexProgramTail(source); // there may be some whitespace left at the end of the program

        writeln("---------------------------------------------");
        writeln("Source was successfully parsed.");
        if (source.offset < source.length) {
            debugWrite(source, "Not all of the input was consumed.");
            stderr.writeln("Next byte is: ", source.front);
            return 1;
        } else {
            writeln("All input has been consumed.");
            return 0;
        }
    } else {
        stderr.writeln("Failed to parse the source.");
        return 1;
    }
}
