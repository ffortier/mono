package io.github.ffortier.jasm.core;

public class JasmCompilationException extends JasmException {
    public JasmCompilationException(String message) {
        super(message);
    }

    public JasmCompilationException(String message, Exception cause) {
        super(message, cause);
    }
}
