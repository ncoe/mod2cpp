module compiler.source;

import std.file;

private struct Position {
    size_t lineNumber = 1;
    size_t lineOffset = 0;
    size_t currOffset = 0;
}

public class Source {
    private Position[] stack;
    private Position maxDepth;
    private Position pos;
    private ubyte[] text;
    debug string debugWindow;

    public this(string fileName) {
        text = cast(ubyte[])readText(fileName);
        debug debugWindow = makeWindow();
    }

    public void reset() nothrow {
        stack.length = 0;
        pos = Position(1, 0, 0);
        debug debugWindow = makeWindow();
    }

    public auto depth() nothrow {
        return stack.length;
    }

    ///////////////////////////////////////////////////////

    public void bookmark() nothrow {
        stack ~= pos;
    }

    public void rollback() nothrow
    in (stack.length > 0)
    do {
        updateDepth();
        pos = stack[$-1];
        stack.length--;
        debug debugWindow = makeWindow();
    }

    public void commit() nothrow {
        stack.length--;
    }

    ///////////////////////////////////////////////////////

    public bool empty() nothrow {
        return pos.currOffset >= text.length;
    }

    public ubyte front() nothrow {
        return text[pos.currOffset];
    }

    public void popFront() nothrow {
        pos.currOffset++;
        debug debugWindow = makeWindow();
    }

    ///////////////////////////////////////////////////////

    public ubyte previous() nothrow {
        if (pos.currOffset > 0) {
            return text[pos.currOffset - 1];
        } else {
            return 0;
        }
    }

    public ubyte next() nothrow {
        if (pos.currOffset + 1 < text.length) {
            return text[pos.currOffset + 1];
        } else {
            return 0;
        }
    }

    public size_t offset() nothrow {
        return pos.currOffset;
    }

    public size_t length() nothrow {
        return text.length;
    }

    public void updateLine() nothrow {
        pos.lineNumber++;
        pos.lineOffset = pos.currOffset;
    }

    private void updateDepth() nothrow {
        if (pos.currOffset > maxDepth.currOffset) {
            maxDepth = pos;
        }
    }

    ///////////////////////////////////////////////////////

    public void writeErrorContext(OutputRange)(OutputRange output) {
        if (pos.currOffset < maxDepth.currOffset) {
            output.writeln("========== MAX DEPTH ==========");

            auto end = maxDepth.lineOffset;
            while (end < text.length && text[end] != '\n' && text[end] != '\r') {
                end++;
            }

            string snippet = cast(string) text[maxDepth.lineOffset .. end];
            output.writefln("%05d: %s", maxDepth.lineNumber, snippet);
            output.write("       ");
            foreach (_; maxDepth.lineOffset .. maxDepth.currOffset) {
                output.write(' ');
            }
            output.writeln('^');
        }

        output.writeln("========== CURRENT ==========");

        auto end = pos.lineOffset;
        while (end < text.length && text[end] != '\n' && text[end] != '\r') {
            end++;
        }

        string snippet = cast(string) text[pos.lineOffset .. end];
        output.writefln("%05d: %s", pos.lineNumber, snippet);
        output.write("       ");
        foreach (_; pos.lineOffset .. pos.currOffset) {
            output.write(' ');
        }
        output.writeln('^');
    }

    ///////////////////////////////////////////////////////

    version(none) {
        override string toString() const {
            import std.algorithm.comparison;

            auto b = max(0, pos.currOffset - 5);
            auto e = min(pos.currOffset + 5, text.length);

            return cast(string) text[b..e];
        }

        void toString(scope void delegate(const(char)[]) sink) const {
            import std.algorithm.comparison;

            auto b = max(0, pos.currOffset - 5);
            auto e = min(pos.currOffset + 5, text.length);

            sink(cast(char[])text[b..e]);
        }
    }

    private debug string makeWindow() nothrow {
        import std.algorithm.comparison;

        enum windowSize = 10;
        auto b = max(pos.currOffset - windowSize, 0);
        auto e = min(pos.currOffset + windowSize, text.length);

        if (b < e) {
            import std.array;

            auto builder = appender!string;
            if (b < pos.currOffset) {
                builder ~= cast(string) text[b .. pos.currOffset];
            }
            builder.put('@');
            if (pos.currOffset < text.length) {
                builder.put(text[pos.currOffset]);
                builder.put('@');
                if (pos.currOffset + 1 < e) {
                    builder ~= cast(string) text[pos.currOffset + 1 .. e];
                }
            }

            return builder.data;
        } else {
            return "<Unknown Error>";
        }
    }
}
