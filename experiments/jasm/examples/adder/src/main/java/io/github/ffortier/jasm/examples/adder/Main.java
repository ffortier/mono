package io.github.ffortier.jasm.examples.adder;

import java.nio.file.Files;
import java.nio.file.Path;

import io.github.ffortier.jasm.core.JIT;

public class Main {
    public static void main(String[] args) throws Exception {
        Adder adder;

        try (final var in = Files.newInputStream(Path.of(args[0]))) {
            adder = JIT.compileAndInstantiate(in, Adder.class, null);
        }

        System.out.println(adder.add(35, 34));
    }
}
