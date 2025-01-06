package io.github.ffortier.jasm.binary;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.List;
import java.util.Optional;

import static io.github.ffortier.jasm.binary.BinaryReader.leb128;
import static io.github.ffortier.jasm.binary.BinaryReader.vec;

public sealed interface Section permits
        Section.CustomSection,
        Section.TypeSection,
        Section.ImportSection,
        Section.FunctionSection,
        Section.TableSection,
        Section.MemorySection,
        Section.GlobalSection,
        Section.ExportSection,
        Section.StartSection,
        Section.ElementSection,
        Section.CodeSection,
        Section.DataSection,
        Section.DataCountSection {
    static Optional<Section> read(BufferedInputStream in) throws IOException {
        var sectionId = in.read();

        if (sectionId < 0) {
            return Optional.empty();
        }

        final var size = leb128(in);
        final var bb = ByteBuffer
                .wrap(in.readNBytes(size))
                .order(ByteOrder.LITTLE_ENDIAN);

        final var section = switch (sectionId) {
            case 0 -> CustomSection.read(bb);
            case 1 -> TypeSection.read(bb);
            case 2 -> ImportSection.read(bb);
            case 3 -> FunctionSection.read(bb);
            case 4 -> TableSection.read(bb);
            case 5 -> MemorySection.read(bb);
            case 6 -> GlobalSection.read(bb);
            case 7 -> ExportSection.read(bb);
            case 8 -> StartSection.read(bb);
            case 9 -> ElementSection.read(bb);
            case 10 -> CodeSection.read(bb);
            case 11 -> DataSection.read(bb);
            case 12 -> DataCountSection.read(bb);
            default -> throw new UnsupportedOperationException("Unknown section id %d".formatted(sectionId));
        };

        return Optional.of(section);
    }

    private static <T extends Section> T notImplemented(Class<T> sectionType) {
        throw new UnsupportedOperationException("Not implemented %s".formatted(sectionType.getName()));
    }

    record CustomSection() implements Section {
        public static CustomSection read(ByteBuffer bb) {
            return notImplemented(CustomSection.class);
        }
    }

    record TypeSection(List<FuncType> types) implements Section {
        public static TypeSection read(ByteBuffer bb) {
            return new TypeSection(vec(bb, bbb -> {
                final var typeId = bb.get();

                if (typeId != 0x60) {
                    throw new UnsupportedOperationException("Unsupported type with id %02x".formatted(typeId));
                }

                return FuncType.read(bb);
            }));
        }
    }

    record ImportSection(List<Import> imports) implements Section {
        public static ImportSection read(ByteBuffer bb) {
            return new ImportSection(vec(bb, Import::read));
        }
    }

    record FunctionSection(List<Index.TypeIdx> typeIndices) implements Section {
        public static FunctionSection read(ByteBuffer bb) {
            return new FunctionSection(vec(bb, bbb -> new Index.TypeIdx(leb128(bbb))));
        }
    }

    record TableSection(List<Table> tables) implements Section {
        public static TableSection read(ByteBuffer bb) {
            return new TableSection(vec(bb, Table::read));
        }
    }

    record MemorySection(List<Memory> memories) implements Section {
        public static MemorySection read(ByteBuffer bb) {
            return new MemorySection(vec(bb, Memory::read));
        }
    }

    record GlobalSection(List<Global> globals) implements Section {
        public static GlobalSection read(ByteBuffer bb) {
            return Section.notImplemented(GlobalSection.class);
        }
    }

    record ExportSection(List<Export> exports) implements Section {
        public static ExportSection read(ByteBuffer bb) {
            return new ExportSection(vec(bb, Export::read));
        }
    }

    record StartSection(Start start) implements Section {
        public static StartSection read(ByteBuffer bb) {
            return notImplemented(StartSection.class);
        }
    }

    record ElementSection(List<Element> elements) implements Section {
        public static ElementSection read(ByteBuffer bb) {
            return notImplemented(ElementSection.class);
        }
    }

    record CodeSection(List<Code> codes) implements Section {
        public static CodeSection read(ByteBuffer bb) {
            return new CodeSection(vec(bb, Code::read));
        }
    }

    record DataSection(List<Data> data) implements Section {
        public static DataSection read(ByteBuffer bb) {
            return new DataSection(vec(bb, Data::read));
        }
    }

    record DataCountSection() implements Section {
        public static DataCountSection read(ByteBuffer bb) {
            return notImplemented(DataCountSection.class);
        }
    }
}
