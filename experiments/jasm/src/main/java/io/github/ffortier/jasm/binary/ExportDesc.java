package io.github.ffortier.jasm.binary;

import java.nio.ByteBuffer;

import static io.github.ffortier.jasm.binary.BinaryReader.leb128;

public sealed interface ExportDesc permits
        ExportDesc.Func,
        ExportDesc.Mem,
        ExportDesc.Global,
        ExportDesc.Table {
    static ExportDesc read(ByteBuffer bb) {
        final var type = bb.get();

        return switch (type) {
            case 0x00 -> new Func(new Index.FuncIdx(leb128(bb)));
            case 0x01 -> new Table(new Index.TableIdx(leb128(bb)));
            case 0x02 -> new Mem(new Index.MemIdx(leb128(bb)));
            case 0x03 -> new Global(new Index.GlobalIdx(leb128(bb)));
            default -> throw new UnsupportedOperationException("Unsupported export type %02x".formatted(type));
        };
    }

    record Func(Index.FuncIdx idx) implements ExportDesc {
    }

    record Table(Index.TableIdx idx) implements ExportDesc {
    }

    record Mem(Index.MemIdx idx) implements ExportDesc {
    }

    record Global(Index.GlobalIdx idx) implements ExportDesc {
    }
}
