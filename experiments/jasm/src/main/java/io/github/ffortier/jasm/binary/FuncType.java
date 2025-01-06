package io.github.ffortier.jasm.binary;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;

import static io.github.ffortier.jasm.binary.BinaryReader.leb128;
import static java.util.Collections.unmodifiableList;

public record FuncType(List<ValType> args, List<ValType> rets) {
    public static FuncType read(ByteBuffer data) {
        final var argLen = leb128(data);
        final var args = new ArrayList<ValType>();

        for (int i = 0; i < argLen; i++) {
            args.add(ValType.get(data.get()));
        }

        final var retLen = leb128(data);
        final var rets = new ArrayList<ValType>();

        for (int i = 0; i < retLen; i++) {
            rets.add(ValType.get(data.get()));
        }

        return new FuncType(unmodifiableList(args), unmodifiableList(rets));
    }
}
