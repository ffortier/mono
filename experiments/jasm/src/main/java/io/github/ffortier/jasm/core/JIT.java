package io.github.ffortier.jasm.core;

import java.io.InputStream;

public class JIT {
    public static <T> Class<? extends T> compile(InputStream wasmBlob, Class<T> interfaceClass)
            throws JasmCompilationException {
        throw new UnsupportedOperationException("Not implemented yet");
    }

    public static <T> T instantiate(Class<? extends T> compiledClass, Object imports)
            throws JasmInstantiationException {
        try {
            final var constructor = compiledClass.getConstructor(Object.class);

            return constructor.newInstance(imports);
        } catch (ReflectiveOperationException e) {
            throw new JasmInstantiationException("Failed to instantiate class %s", e);
        }
    }

    public static <T> T compileAndInstantiate(InputStream wasmBlob, Class<T> interfaceClass, Object imports)
            throws JasmInstantiationException, JasmCompilationException {
        final var compiledClass = compile(wasmBlob, interfaceClass);

        return instantiate(compiledClass, imports);
    }
}
