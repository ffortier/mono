package io.github.ffortier.jasm.binary;

import java.nio.ByteBuffer;

import static io.github.ffortier.jasm.binary.BinaryReader.leb128;
import static java.util.Objects.requireNonNull;

public record Data(Data.Mode mode, Index.MemIdx memory, Expr offset, byte[] initialBytes) {
    public Data {
        switch (mode) {
            case ACTIVE -> {
                requireNonNull(memory, "memory is required for active data block");
                requireNonNull(offset, "offset is required for active data block");
            }
            case PASSIVE -> {
                requireNull(memory, "memory is forbidden for passive data block");
                requireNull(offset, "offset is forbidden for passive data block");
            }
        }
    }

    public static Data read(ByteBuffer bb) {
        final var bitField = leb128(bb);

        return switch (bitField) {
            case 0 -> new Data(Mode.ACTIVE, new Index.MemIdx(0), Expr.read(bb), readBytes(bb));
            case 1 -> new Data(Mode.PASSIVE, null, null, readBytes(bb));
            case 2 -> new Data(Mode.ACTIVE, new Index.MemIdx(leb128(bb)), Expr.read(bb), readBytes(bb));
            default -> throw new UnsupportedOperationException("Unexpected bit field for data %d".formatted(bitField));
        };
    }

    private static byte[] readBytes(ByteBuffer bb) {
        final var len = leb128(bb);
        final var bytes = new byte[len];

        bb.get(bytes);

        return bytes;
    }

    private static void requireNull(Object val, String message) {
        if (val != null) {
            throw new IllegalArgumentException(message);
        }
    }

    public enum Mode {
        ACTIVE,
        PASSIVE
    }
}
