package io.github.ffortier.jasm.cli;

import java.nio.file.Path;
import java.util.concurrent.Callable;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.github.ffortier.jasm.core.binary.WebAssembly;
import picocli.CommandLine.Command;
import picocli.CommandLine.Parameters;

@Command(description = "Inspect a wasm file and dump the content")
public class Inspect implements Callable<Integer> {

    private static final Logger log = LoggerFactory.getLogger(Inspect.class);

    @Parameters(index = "0", arity = "1", description = "The wasm file to inspect", preprocessor = BazelPathPreprocessor.class)
    private Path wasm;

    @Override
    public Integer call() throws Exception {
        WebAssembly.readSections(wasm, section -> {
            System.out.println("=====");
            System.out.println(section);
            System.out.println("=====");
            System.out.println();
        });

        return 0;
    }

}
