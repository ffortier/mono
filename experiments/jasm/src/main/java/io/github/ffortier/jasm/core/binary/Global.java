package io.github.ffortier.jasm.core.binary;

import java.nio.ByteBuffer;

public record Global(ValType t, boolean mut, Expr expr) {
    public static Global read(ByteBuffer bb) {
        final var t = ValType.get(bb.get());
        final var mut = bb.get() == 1;
        final var expr = Expr.read(bb);

        return new Global(t, mut, expr);
    }
}
