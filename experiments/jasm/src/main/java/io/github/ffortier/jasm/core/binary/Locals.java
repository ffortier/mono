package io.github.ffortier.jasm.core.binary;

import static io.github.ffortier.jasm.core.binary.BinaryReader.leb128;

import java.nio.ByteBuffer;

public record Locals(int n, ValType t) {
    public static Locals read(ByteBuffer bb) {
        final var n = leb128(bb);
        final var t = ValType.get(bb.get());

        return new Locals(n, t);
    }
}
