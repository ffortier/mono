package io.github.ffortier.jasm.core;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.nio.file.Paths;
import java.util.Optional;

import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Opcodes;
import org.objectweb.asm.Type;

import io.github.ffortier.jasm.core.binary.Export;
import io.github.ffortier.jasm.core.binary.ExportDesc;
import io.github.ffortier.jasm.core.binary.WebAssembly;
import io.github.ffortier.jasm.core.binary.WebAssemblyModule;

public class JIT {
    @SuppressWarnings("unchecked")
    public static <T> Class<? extends T> compile(InputStream wasmBlob, Class<T> interfaceClass)
            throws JasmCompilationException {
        final var className = "W";

        WebAssemblyModule module;

        try {
            module = WebAssembly.compile(wasmBlob);
        } catch (IOException e) {
            throw new JasmCompilationException("Could not parse web assembly module", e);
        }

        final var cw = new ClassWriter(ClassWriter.COMPUTE_FRAMES);

        cw.visit(Opcodes.V21, // Java version
                Opcodes.ACC_PUBLIC + Opcodes.ACC_SUPER, // Access flags
                className, // Class name
                null, // Generic signature
                "java/lang/Object", // Superclass
                new String[] { Type.getInternalName(interfaceClass) }); // Interfaces

        // Constructor
        final var constructor = cw.visitMethod(Opcodes.ACC_PUBLIC, "<init>", "()V", null, null);
        constructor.visitCode();
        constructor.visitVarInsn(Opcodes.ALOAD, 0); // Load 'this'
        constructor.visitMethodInsn(Opcodes.INVOKESPECIAL, "java/lang/Object", "<init>", "()V", false); // Call super
        // constructor
        constructor.visitInsn(Opcodes.RETURN);
        constructor.visitMaxs(1, 1);
        constructor.visitEnd();

        for (final var func : module.funcs()) {
            // TODO: Implement function
        }

        for (final var interfaceMethod : interfaceClass.getMethods()) {
            switch (findExport(module, interfaceMethod).desc()) {
                case ExportDesc.Func f -> {

                }
                default -> {
                    throw new UnsupportedOperationException();
                }
            }
        }

        cw.visitEnd();

        byte[] bytecode = cw.toByteArray();

        // Use a ClassLoader to load the generated class
        ClassLoader classLoader = new ClassLoader() {
            @Override
            protected Class<?> findClass(String name) throws ClassNotFoundException {
                if (name.equals(className)) {
                    return defineClass(name, bytecode, 0, bytecode.length);
                }
                return super.findClass(name);
            }
        };

        try {
            return (Class<? extends T>) classLoader.loadClass(className);
        } catch (ClassNotFoundException e) {
            throw new JasmCompilationException("Could not load generated class", e);
        }
    }

    private static Export findExport(WebAssemblyModule module, Method interfaceMethod) throws JasmCompilationException {
        for (final var export : module.exports()) {
            if (interfaceMethod.getName().equals(export.nm())) {
                // TODO: Check signature
                return export;
            }
        }

        throw new JasmCompilationException("Could not find export for method %s".formatted(interfaceMethod));
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

    // public interface MyInterface {
    // String myMethod(int value);
    // }

    // public static void main(String[] args) throws Exception {
    // String className = "GeneratedImplementation";
    // String interfaceName = Type.getInternalName(MyInterface.class);

    // ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_FRAMES); // Important
    // for Java 7+

    // // Define the class
    // cw.visit(Opcodes.V1_8, // Java version
    // Opcodes.ACC_PUBLIC + Opcodes.ACC_SUPER, // Access flags
    // className, // Class name
    // null, // Generic signature
    // "java/lang/Object", // Superclass
    // new String[] { interfaceName }); // Interfaces

    // // Constructor
    // MethodVisitor constructor = cw.visitMethod(Opcodes.ACC_PUBLIC, "<init>",
    // "()V", null, null);
    // constructor.visitCode();
    // constructor.visitVarInsn(Opcodes.ALOAD, 0); // Load 'this'
    // constructor.visitMethodInsn(Opcodes.INVOKESPECIAL, "java/lang/Object",
    // "<init>", "()V", false); // Call super
    // // constructor
    // constructor.visitInsn(Opcodes.RETURN);
    // constructor.visitMaxs(1, 1);
    // constructor.visitEnd();

    // // Implement the interface method
    // MethodVisitor mv = cw.visitMethod(Opcodes.ACC_PUBLIC, "myMethod",
    // "(I)Ljava/lang/String;", null, null);
    // mv.visitCode();

    // // Example implementation: return "Value: " + value
    // mv.visitLdcInsn("Value: "); // Push "Value: " onto the stack
    // mv.visitVarInsn(Opcodes.ILOAD, 1); // Load the integer argument
    // mv.visitMethodInsn(Opcodes.INVOKESTATIC, "java/lang/String", "valueOf",
    // "(I)Ljava/lang/String;", false); // Convert
    // // int
    // // to
    // // String
    // mv.visitMethodInsn(Opcodes.INVOKEVIRTUAL, "java/lang/String", "concat",
    // "(Ljava/lang/String;)Ljava/lang/String;", false); // Concatenate strings

    // mv.visitInsn(Opcodes.ARETURN); // Return the string
    // mv.visitMaxs(3, 2); // Correct max stack and local variables
    // mv.visitEnd();

    // cw.visitEnd();

    // byte[] bytecode = cw.toByteArray();

    // // Optional: Write bytecode to file for inspection with javap -c
    // Files.write(Paths.get(className + ".class"), bytecode);

    // // Use a ClassLoader to load the generated class
    // ClassLoader classLoader = new ClassLoader() {
    // @Override
    // protected Class<?> findClass(String name) throws ClassNotFoundException {
    // if (name.equals(className)) {
    // return defineClass(name, bytecode, 0, bytecode.length);
    // }
    // return super.findClass(name);
    // }
    // };
    // Class<?> generatedClass = classLoader.loadClass(className);

    // // Create an instance and use it
    // MyInterface instance = (MyInterface)
    // generatedClass.getDeclaredConstructor().newInstance();
    // String result = instance.myMethod(42);
    // System.out.println(result); // Output: Value: 42

    // // Example of using TraceClassVisitor to print out the generated code
    // ClassReader cr = new ClassReader(bytecode);
    // TraceClassVisitor tcv = new TraceClassVisitor(new PrintWriter(System.out));
    // cr.accept(tcv, 0);

    // }
}
