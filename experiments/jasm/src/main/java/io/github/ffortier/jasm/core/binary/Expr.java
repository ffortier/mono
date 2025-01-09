package io.github.ffortier.jasm.core.binary;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;

public record Expr(List<Instruction> instructions) {
    public static Expr read(ByteBuffer bb) {
        final var instructions = new ArrayList<Instruction>();

        var instruction = Instruction.read(bb);

        while (instruction.opcode() != WebAssemblyOpcode.END) {
            instructions.add(instruction);
            instruction = Instruction.read(bb);
        }

        return new Expr(instructions);
    }
}
