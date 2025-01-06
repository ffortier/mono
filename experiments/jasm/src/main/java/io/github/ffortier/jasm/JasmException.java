package io.github.ffortier.jasm;

public class JasmException extends Exception {
    public JasmException(String message, Exception cause) {
        super(message, cause);
    }

    public JasmException(String message) {
        super(message);
    }
}
