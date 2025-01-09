package io.github.ffortier.jasm.core.binary;

import java.nio.ByteBuffer;

public record MemType(Limits lib) {
    public static MemType read(ByteBuffer bb) {
        return new MemType(Limits.read(bb));
    }
}
