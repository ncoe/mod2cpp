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

    public void reset() {
        stack.length = 0;
        pos = Position(1, 0, 0);
    }

    public void pushBookmark() {
        stack ~= pos;
    }

    public void popBookmark() in {
        assert(stack.length > 0);
    } body {
        pos = stack[$-1];
        stack.length--;
    }

    public void discardBookmark() {
        stack.length--;
    }

    public bool empty() {
        return pos.currOffset >= text.length;
    }

    public ubyte front() {
        return text[pos.currOffset];
    }

    public void popFront() {
        pos.currOffset++;
    }

    public size_t offset() {
        return pos.currOffset;
    }

    public size_t length() {
        return text.length;
    }

    public void updateLine() {
        pos.lineNumber++;
        pos.lineOffset = pos.currOffset;
    }

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
