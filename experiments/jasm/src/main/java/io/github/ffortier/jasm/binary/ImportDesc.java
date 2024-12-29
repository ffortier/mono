package io.github.ffortier.jasm.binary;

import java.nio.ByteBuffer;

import static io.github.ffortier.jasm.binary.BinaryReader.leb128;

public sealed interface ImportDesc permits
        ImportDesc.Func,
        ImportDesc.Mem,
        ImportDesc.Table,
        ImportDesc.Global {
    static ImportDesc read(ByteBuffer bb) {
        final var type = bb.get();

        return switch (type) {
            case 0x00 -> new Func(new Index.TypeIdx(leb128(bb)));
            case 0x01 -> new Table(TableType.read(bb));
            case 0x02 -> new Mem(MemType.read(bb));
            case 0x03 -> new Global(GlobalType.read(bb));
            default -> throw new UnsupportedOperationException("Unsupported import desc %02x".formatted(type));
        };
    }

    record Func(Index.TypeIdx idx) implements ImportDesc {
    }

    record Mem(MemType memType) implements ImportDesc {
    }

    record Table(TableType tableType) implements ImportDesc {
    }

    record Global(GlobalType global) implements ImportDesc {
    }
}
