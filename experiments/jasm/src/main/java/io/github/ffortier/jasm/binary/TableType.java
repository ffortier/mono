package io.github.ffortier.jasm.binary;

import java.nio.ByteBuffer;

public record TableType(ValType.RefType refType, Limits lib) {
    public static TableType read(ByteBuffer bb) {
        int valTypeId = bb.get();

        if (ValType.get(valTypeId) instanceof ValType.RefType refType) {
            final var limits = Limits.read(bb);

            return new TableType(refType, limits);
        }

        throw new UnsupportedOperationException("Unsupported val type for table type %02x".formatted(valTypeId));
    }
}
