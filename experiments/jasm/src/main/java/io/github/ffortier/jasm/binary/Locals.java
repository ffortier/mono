package io.github.ffortier.jasm.binary;

import java.nio.ByteBuffer;

import static io.github.ffortier.jasm.binary.BinaryReader.leb128;

public record Locals(int n, ValType t) {
    public static Locals read(ByteBuffer bb) {
        final var n = leb128(bb);
        final var t = ValType.get(bb.get());

        return new Locals(n, t);
    }
}
