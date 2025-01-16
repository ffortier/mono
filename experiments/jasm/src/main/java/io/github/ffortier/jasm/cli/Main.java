package io.github.ffortier.jasm.cli;

import picocli.CommandLine;
import picocli.CommandLine.Command;

@Command(name = "jasm", description = "Jasm is a tool to cross-compile Web Assembly to the JVM just for fun")
public class Main {
    public static void main(String[] args) {
        final var status = new CommandLine(new Main())
                .addSubcommand("inspect", new Inspect())
                .addSubcommand("interface", new Interface())
                .execute(args);

        System.exit(status);
    }
}