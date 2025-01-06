package io.github.ffortier.jasm.binary;

import java.nio.ByteBuffer;

public record Memory(Limits limits) {
    public static Memory read(ByteBuffer bb) {
        return new Memory(Limits.read(bb));
    }
}
