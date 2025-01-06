package io.github.ffortier.jasm.binary;

import java.nio.ByteBuffer;

import static io.github.ffortier.jasm.binary.BinaryReader.leb128;

public record Limits(int min, int max) {
    public static Limits read(ByteBuffer bb) {
        byte flag = bb.get();

        return switch (flag) {
            case 0x00 -> new Limits(leb128(bb), -1);
            case 0x01 -> new Limits(leb128(bb), leb128(bb));
            default -> throw new UnsupportedOperationException("Unexpected flag for limits %02x".formatted(flag));
        };
    }
}
