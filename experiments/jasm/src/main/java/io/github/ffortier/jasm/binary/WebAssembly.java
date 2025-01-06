package io.github.ffortier.jasm.binary;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class WebAssembly {
    private static final byte[] WASM_HEADER = { 0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00 };

    private static void readWasmHeader(BufferedInputStream in) throws IOException {
        byte[] buf = in.readNBytes(WASM_HEADER.length);

        if (!Arrays.equals(WASM_HEADER, buf)) {
            throw new IOException("invalid wasm header");
        }
    }

    public Module compile(InputStream in) throws IOException {
        try (final var buffered = new BufferedInputStream(in)) {
            return compile(buffered);
        }
    }

    public Module compile(BufferedInputStream in) throws IOException {
        readWasmHeader(in);

        final var moduleBuilder = Module.builder();

        Section.FunctionSection functionSection = null;
        Section.CodeSection codeSection = null;

        while (true) {
            switch (Section.read(in).orElse(null)) {
                case null -> {
                    if (functionSection != null && codeSection != null) {
                        moduleBuilder.funcs(buildFuncs(codeSection, functionSection));
                    }

                    return moduleBuilder.build();
                }
                case Section.CodeSection _codeSection -> {
                    codeSection = _codeSection;
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
                    functionSection = _functionSection;
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
        }
    }

    private List<Func> buildFuncs(Section.CodeSection codeSection, Section.FunctionSection functionSection) {
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
