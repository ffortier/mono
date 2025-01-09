package io.github.ffortier.jasm.core.binary;

import static io.github.ffortier.jasm.core.binary.BinaryReader.leb128;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;

public record Code(List<Locals> locals, Expr body) {
    public static Code read(ByteBuffer bb) {
        final var size = leb128(bb);
        final var bytes = new byte[size];

        bb.get(bytes);

        final var bbb = ByteBuffer.wrap(bytes);
        final var len = leb128(bbb);
        final var locals = new ArrayList<Locals>();

        for (int i = 0; i < len; i++) {
            locals.add(Locals.read(bbb));
        }

        return new Code(locals, Expr.read(bbb));
    }

}
