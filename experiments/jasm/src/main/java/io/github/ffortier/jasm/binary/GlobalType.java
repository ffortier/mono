package io.github.ffortier.jasm.binary;

import java.nio.ByteBuffer;

public record GlobalType(ValType valType, boolean mut) {
    public static GlobalType read(ByteBuffer bb) {
        final var valType = ValType.get(bb.get());
        final var mut = bb.get() != 0;

        return new GlobalType(valType, mut);
    }
}
