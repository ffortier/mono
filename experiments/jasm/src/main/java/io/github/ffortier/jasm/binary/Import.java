package io.github.ffortier.jasm.binary;

import java.nio.ByteBuffer;

import static io.github.ffortier.jasm.binary.BinaryReader.name;

public record Import(String mod, String nm, ImportDesc desc) {

    public static Import read(ByteBuffer bb) {
        final var mod = name(bb);
        final var nm = name(bb);
        final var desc = ImportDesc.read(bb);

        return new Import(mod, nm, desc);
    }
}
