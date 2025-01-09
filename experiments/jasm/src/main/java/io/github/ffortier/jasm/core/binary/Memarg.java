package io.github.ffortier.jasm.core.binary;

import java.nio.ByteBuffer;

public record Memarg(int align, int offset) {
    public static Memarg read(ByteBuffer bb) {
        final var align = BinaryReader.leb128(bb);
        final var offset = BinaryReader.leb128(bb);

        return new Memarg(align, offset);
    }
}