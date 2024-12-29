package io.github.ffortier.jasm.binary;

import java.nio.ByteBuffer;

import io.github.ffortier.jasm.WebAssemblyOpcode;

public record Instruction(WebAssemblyOpcode opcode) {

    public static Instruction read(ByteBuffer bb) {
        throw new UnsupportedOperationException();
    }
}
