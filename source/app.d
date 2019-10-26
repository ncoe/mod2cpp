import std.stdio;

import compiler.source;
import compiler.state;
import grammar.declaration;

void main(string[] args) {
    //stderr.writeln(args);

    if (args.length < 1) {
        stderr.writeln("Expected a source file to be given as an argument.");
    }

    auto fileName = args[1];

    stderr.writeln("Processing the source file: ", fileName);
    auto source = new Source(fileName);
    parse(source);
}

void parse(Source source) in {
    assert(source);
} body {
    auto state = new State();
    compilationModule(source, state);
    if (state.success) {
        //consumeWhitespace(source);
        if (source.offset < source.length) {
            stderr.writeln("Failed to completely consume the program source.");
            source.writeErrorContext(stderr);
            stderr.writeln("Next byte: ", source.front);
        } else {
            writeln("Successfully parsed the program source,");
        }
    }
}
