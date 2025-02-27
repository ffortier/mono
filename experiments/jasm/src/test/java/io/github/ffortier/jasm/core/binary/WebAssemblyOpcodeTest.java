package io.github.ffortier.jasm.core.binary;

import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

import io.github.ffortier.jasm.core.binary.WebAssemblyOpcode;

public class WebAssemblyOpcodeTest {
    @Test
    public void test() {
        final var opcodes = WebAssemblyOpcode.values();

        for (int i = 0; i < 16; i++) {
            for (int j = 0; j < 16 && ((i * 16) + j) < opcodes.length; j++) {
                System.out.print(opcodes[(i * 16) + j].toString() + "\t");
            }
            System.out.println();
        }
    }
}
