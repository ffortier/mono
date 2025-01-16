package io.github.ffortier.jasm.core.binary;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicReference;
import java.util.function.Consumer;

public class WebAssembly {
    private static final byte[] WASM_HEADER = { 0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00 };

    private static void readWasmHeader(BufferedInputStream in) throws IOException {
        byte[] buf = in.readNBytes(WASM_HEADER.length);

        if (!Arrays.equals(WASM_HEADER, buf)) {
            throw new IOException("invalid wasm header");
        }
    }

    public static WebAssemblyModule compile(Path p) throws IOException {
        try (final var in = Files.newInputStream(p)) {
            return compile(in);
        }
    }

    public static WebAssemblyModule compile(InputStream in) throws IOException {
        try (final var buffered = new BufferedInputStream(in)) {
            return compile(buffered);
        }
    }

    public static WebAssemblyModule compile(BufferedInputStream in) throws IOException {
        final var moduleBuilder = WebAssemblyModule.builder();
        final var functionSection = new AtomicReference<Section.FunctionSection>();
        final var codeSection = new AtomicReference<Section.CodeSection>();

        readSections(in, section -> {
            switch (section) {
                case Section.CodeSection _codeSection -> {
                    codeSection.set(_codeSection);
                }
                case Section.DataSection dataSection -> {
                    moduleBuilder.data(dataSection.data());
                }
                case Section.ElementSection elementSection -> {
                    moduleBuilder.elements(elementSection.elements());
                }
                case Section.ExportSection exportSection -> {
                    moduleBuilder.exports(exportSection.exports());
                }
                case Section.FunctionSection _functionSection -> {
                    functionSection.set(_functionSection);
                }
                case Section.GlobalSection globalSection -> {
                    moduleBuilder.globals(globalSection.globals());
                }
                case Section.ImportSection importSection -> {
                    moduleBuilder.imports(importSection.imports());
                }
                case Section.MemorySection memorySection -> {
                    moduleBuilder.memories(memorySection.memories());
                }
                case Section.StartSection startSection -> {
                    moduleBuilder.start(startSection.start());
                }
                case Section.TableSection tableSection -> {
                    moduleBuilder.tables(tableSection.tables());
                }
                case Section.TypeSection typeSection -> {
                    moduleBuilder.types(typeSection.types());
                }
                case Section.CustomSection customSection -> {
                    // ignored
                }
                case Section.DataCountSection dataCountSection -> {
                    // ignored
                }
            }
        });

        if (functionSection.get() != null && codeSection.get() != null) {
            moduleBuilder.funcs(buildFuncs(codeSection.get(), functionSection.get()));
        }

        return moduleBuilder.build();
    }

    public static void readSections(Path p, Consumer<? super Section> consumer) throws IOException {
        try (final var in = Files.newInputStream(p)) {
            readSections(in, consumer);
        }
    }

    public static void readSections(InputStream in, Consumer<? super Section> consumer) throws IOException {
        try (final var buf = new BufferedInputStream(in)) {
            readSections(buf, consumer);
        }
    }

    public static void readSections(BufferedInputStream in, Consumer<? super Section> consumer) throws IOException {
        readWasmHeader(in);

        Optional<Section> section;

        do {
            section = Section.read(in);

            section.ifPresent(consumer);
        } while (section.isPresent());
    }

    private static List<Func> buildFuncs(Section.CodeSection codeSection, Section.FunctionSection functionSection) {
        if (codeSection.codes().size() != functionSection.typeIndices().size()) {
            throw new IllegalStateException(
                    "Expected code section and function section to contain the same number of elements");
        }

        final var count = codeSection.codes().size();
        final var funcs = new ArrayList<Func>(count);

        for (int i = 0; i < count; i++) {
            final var code = codeSection.codes().get(i);
            final var funcType = functionSection.typeIndices().get(i);

            funcs.add(new Func(funcType, code.locals(), code.body()));
        }

        return funcs;
    }
}
