package io.github.ffortier.jasm.cli;

import java.nio.file.Path;
import java.util.Map;
import java.util.Stack;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import picocli.CommandLine.IParameterPreprocessor;
import picocli.CommandLine.Model.ArgSpec;
import picocli.CommandLine.Model.CommandSpec;

public class BazelPathPreprocessor implements IParameterPreprocessor {
    private static final Logger log = LoggerFactory.getLogger(Inspect.class);

    public static Path resolve(Path relative) {
        if (System.getenv("BUILD_WORKING_DIRECTORY") instanceof String wd) {
            return Path.of(wd).resolve(relative);
        }

        return relative.toAbsolutePath();
    }

    @Override
    public boolean preprocess(Stack<String> args, CommandSpec commandSpec, ArgSpec argSpec, Map<String, Object> info) {
        if (System.getenv("BUILD_WORKING_DIRECTORY") instanceof String wd) {
            final var root = Path.of(wd);

            log.debug("Bazel working directory detected with path {}", root);

            args.replaceAll(a -> root.resolve(a).toString());
        }

        return false;
    }
}
