package io.github.ffortier.jasm.binary;

import java.nio.ByteBuffer;

import static io.github.ffortier.jasm.binary.BinaryReader.name;

public record Export(String nm, ExportDesc desc) {
    public static Export read(ByteBuffer bb) {
        final var nm = name(bb);
        final var desc = ExportDesc.read(bb);

        return new Export(nm, desc);
    }
}
