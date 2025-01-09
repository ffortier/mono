package io.github.ffortier.jasm.cli;

import java.nio.file.Path;
import java.util.concurrent.Callable;

import io.github.ffortier.jasm.core.binary.WebAssembly;
import picocli.CommandLine.Command;
import picocli.CommandLine.Parameters;

@Command(description = "Inspect a wasm file and dump the content")
public class Inspect implements Callable<Integer> {

    @Parameters(index = "0", arity = "1", description = "The wasm file to inspect", preprocessor = BazelPathPreprocessor.class)
    private Path wasm;

    @Override
    public Integer call() throws Exception {
        System.out.println(WebAssembly.compile(wasm));

        return 0;
    }

}
