package io.github.ffortier.jasm.binary;

import java.nio.ByteBuffer;

public record Memarg() {
    public static Memarg read(ByteBuffer bb) {
        throw new UnsupportedOperationException("not implemented");
    }
}