package io.github.ffortier.jasm.cli;

import java.io.IOException;
import java.io.PrintStream;
import java.nio.file.Path;
import java.util.concurrent.Callable;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import io.github.ffortier.jasm.core.binary.Export;
import io.github.ffortier.jasm.core.binary.ExportDesc;
import io.github.ffortier.jasm.core.binary.WebAssembly;
import io.github.ffortier.jasm.core.binary.WebAssemblyModule;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

@Command(description = "Generates an interface based on the imports and exports")
public class Interface implements Callable<Integer> {

    @Parameters(index = "0", arity = "1", description = "The wasm file to inspect", preprocessor = BazelPathPreprocessor.class)
    private Path wasm;

    @Option(description = "Output file (default stdout)", preprocessor = BazelPathPreprocessor.class, names = {
            "-o",
            "--out",
    })
    private Path output;

    @Option(description = "Fully qualified class name (default wasm basename)", names = {
            "-c",
            "-class",
    })
    private String className;

    @Override
    public Integer call() throws Exception {
        if (output == null) {
            renderInterface(System.out);

            return 0;
        }

        try (final var out = new PrintStream(output.toFile())) {
            renderInterface(out);
        }

        return 0;
    }

    private void renderInterface(PrintStream out) throws IOException {
        final var module = WebAssembly.compile(wasm);

        if (className == null) {
            className = toClassName(removeExtension(wasm.getFileName().toString()));
        }

        out.println("/** Generated with jasm */");

        int i = className.lastIndexOf(".");

        if (i >= 0) {
            out.println("package %s;".formatted(className.substring(0, i)));
            out.println();
        }

        out.println("import java.nio.ByteBuffer;");
        out.println();
        out.println("public interface %s {".formatted(className.substring(i + 1)));

        for (final var export : module.exports()) {
            out.println(renderExport(export, module));
        }

        out.println("}");
    }

    private String renderExport(Export export, WebAssemblyModule module) {
        return switch (export.desc()) {
            case ExportDesc.Func func -> renderFunctionDeclaration(func, export.nm(), module);
            case ExportDesc.Global global -> "/* global*/";
            case ExportDesc.Mem global -> "ByteBuffer %s();".formatted(export.nm());
            case ExportDesc.Table global -> "/* table */";
        };
    }

    private String renderFunctionDeclaration(ExportDesc.Func desc, String name, WebAssemblyModule module) {
        final var func = desc.idx().get(module.funcs());
        final var type = func.type().get(module.types());

        if (type.rets().size() != 1) {
            throw new UnsupportedOperationException(
                    "Exactly one return type must be specified for exported function %s but got %s".formatted(name,
                            type.rets()));
        }

        final var args = IntStream.range(0, type.args().size())
                .mapToObj(i -> "%s arg%d".formatted(type.args().get(i).javaType().getTypeName(), i))
                .collect(Collectors.joining(", "));

        return "%s %s(%s);".formatted(type.rets().get(0).javaType().getTypeName(), name, args);
    }

    private String removeExtension(String name) {
        final var i = name.lastIndexOf(".");

        if (i < 0) {
            return name;
        }

        return name.substring(0, i);
    }

    private String toClassName(String name) {
        final var buffer = new StringBuilder();

        for (final var word : name.split("[^a-zA-Z0-9]+")) {
            if (word.isEmpty()) {
                continue;
            }

            buffer.append(capitalize(word));
        }

        int start = 0;

        while (start < buffer.length() && Character.isDigit(buffer.charAt(start))) {
            start += 1;
        }

        return buffer.substring(start);
    }

    private String capitalize(String word) {
        assert word.length() > 1; // Check in parent method

        return Character.toUpperCase(word.charAt(0)) + word.substring(1);
    }
}
