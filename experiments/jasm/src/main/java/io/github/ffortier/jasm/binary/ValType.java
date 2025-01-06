package io.github.ffortier.jasm.binary;

public sealed interface ValType permits ValType.NumType, ValType.VecType, ValType.RefType {
    static ValType get(int id) {
        for (final var valType : ValType.values()) {
            if (valType.id() == id) {
                return valType;
            }
        }

        throw new IllegalArgumentException("Unknown ValType id %02x".formatted(id));
    }

    static ValType[] values() {
        final var numTypes = NumType.values();
        final var vecTypes = VecType.values();
        final var refTypes = RefType.values();

        ValType[] valTypes = new ValType[numTypes.length + vecTypes.length + refTypes.length];

        System.arraycopy(numTypes, 0, valTypes, 0, numTypes.length);
        System.arraycopy(vecTypes, 0, valTypes, numTypes.length, vecTypes.length);
        System.arraycopy(refTypes, 0, valTypes, numTypes.length + vecTypes.length, refTypes.length);

        return valTypes;
    }

    int id();

    enum NumType implements ValType {
        I32(0x7f),
        I64(0x7e),
        F32(0x7d),
        F64(0x7c),
        ;
        private final int id;

        NumType(int id) {
            this.id = id;
        }

        @Override public int id() {
            return id;
        }
    }

    enum VecType implements ValType {
        V128(0x7b),
        ;
        private final int id;

        VecType(int id) {
            this.id = id;
        }

        @Override public int id() {
            return id;
        }
    }

    enum RefType implements ValType {
        FUNC_REF(0x70),
        EXTERN_REF(0x6f),
        ;
        private final int id;

        RefType(int id) {
            this.id = id;
        }

        @Override public int id() {
            return id;
        }
    }
}
