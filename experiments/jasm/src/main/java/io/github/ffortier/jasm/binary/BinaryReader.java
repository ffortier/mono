package io.github.ffortier.jasm.binary;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;

import static java.util.Collections.unmodifiableList;

public class BinaryReader {

    /**
     * Decode unsigned integers
     */
    public static int leb128(BufferedInputStream in) throws IOException {
        int result = 0;
        int shift = 0;

        while (true) {
            int b = in.read();
            result |= (b & 0b0111_1111) << shift;
            if ((b & 0b1000_0000) == 0)
                return result;
            shift += 7;
        }
    }

    public static int leb128(ByteBuffer bb) {
        int result = 0;
        int shift = 0;

        while (true) {
            int b = bb.get();
            result |= (b & 0b0111_1111) << shift;
            if ((b & 0b1000_0000) == 0)
                return result;
            shift += 7;
        }
    }

    public static String name(ByteBuffer bb) {
        final var size = leb128(bb);
        final var bytes = new byte[size];

        bb.get(bytes);

        return StandardCharsets.UTF_8.decode(ByteBuffer.wrap(bytes)).toString();
    }

    public static <T> List<T> vec(ByteBuffer bb, Function<ByteBuffer, T> read) {
        final var len = leb128(bb);
        final var list = new ArrayList<T>(len);

        for (int i = 0; i < len; i++) {
            list.add(read.apply(bb));
        }

        return unmodifiableList(list);
    }

    public static int i32(ByteBuffer bb) {
        int result = 0;
        int shift = 0;
        while (true) {
            byte b = bb.get();
            result |= (b & 0x7f) << shift;
            shift += 7;
            if ((0x80 & b) == 0) {
                if (shift < 32 && (b & 0x40) != 0) {
                    return result | (~0 << shift);
                }
                return result;
            }
        }
    }

    public static long i64(ByteBuffer bb) {
        long result = 0;
        int shift = 0;
        while (true) {
            byte b = bb.get();
            result |= (b & 0x7f) << shift;
            shift += 7;
            if ((0x80 & b) == 0) {
                if (shift < 64 && (b & 0x40) != 0) {
                    return result | (~0 << shift);
                }
                return result;
            }
        }
    }

    public static float f32(ByteBuffer bb) {
        assert bb.order() == ByteOrder.LITTLE_ENDIAN;

        return bb.getFloat();
    }

    public static double f64(ByteBuffer bb) {
        assert bb.order() == ByteOrder.LITTLE_ENDIAN;
        
        return bb.getDouble();
    }
}
