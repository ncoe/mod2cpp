module compiler.source;

import std.file;

private struct Position {
    size_t lineNumber = 1;
    size_t lineOffset = 0;
    size_t currOffset = 0;
}

public class Source {
    private Position[] stack;
    private Position pos;
    private ubyte[] text;

    public this(string fileName) {
        text = cast(ubyte[])readText(fileName);
    }

    public void reset() nothrow {
        stack.length = 0;
        pos = Position(1, 0, 0);
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
        pos = stack[$-1];
        stack.length--;
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
    }

    ///////////////////////////////////////////////////////

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

    ///////////////////////////////////////////////////////

    public void writeErrorContext(OutputRange)(OutputRange output) {
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
}
