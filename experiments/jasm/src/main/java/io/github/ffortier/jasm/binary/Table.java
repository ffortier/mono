package io.github.ffortier.jasm.binary;

import java.nio.ByteBuffer;

public record Table(ValType.RefType et, Limits lim) {
    public static Table read(ByteBuffer bb) {
        final var valType = ValType.get(bb.get());

        if (valType instanceof ValType.RefType et) {
            final var lim = Limits.read(bb);

            return new Table(et, lim);
        }

        throw new UnsupportedOperationException("Expected RefType but got %s".formatted(valType));
    }
}
