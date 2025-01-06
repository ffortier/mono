package io.github.ffortier.jasm;

import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import org.objectweb.asm.*;
import org.objectweb.asm.util.ASMifier;
import org.objectweb.asm.util.TraceClassVisitor;

import java.lang.reflect.InvocationTargetException;

class Main {
    public interface MyInterface {
        String myMethod(int value);
    }

    public static void main(String[] args) throws Exception {
        String className = "GeneratedImplementation";
        String interfaceName = Type.getInternalName(MyInterface.class);

        ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_FRAMES); // Important for Java 7+

        // Define the class
        cw.visit(Opcodes.V1_8, // Java version
                Opcodes.ACC_PUBLIC + Opcodes.ACC_SUPER, // Access flags
                className, // Class name
                null, // Generic signature
                "java/lang/Object", // Superclass
                new String[] { interfaceName }); // Interfaces

        // Constructor
        MethodVisitor constructor = cw.visitMethod(Opcodes.ACC_PUBLIC, "<init>", "()V", null, null);
        constructor.visitCode();
        constructor.visitVarInsn(Opcodes.ALOAD, 0); // Load 'this'
        constructor.visitMethodInsn(Opcodes.INVOKESPECIAL, "java/lang/Object", "<init>", "()V", false); // Call super
                                                                                                        // constructor
        constructor.visitInsn(Opcodes.RETURN);
        constructor.visitMaxs(1, 1);
        constructor.visitEnd();

        // Implement the interface method
        MethodVisitor mv = cw.visitMethod(Opcodes.ACC_PUBLIC, "myMethod", "(I)Ljava/lang/String;", null, null);
        mv.visitCode();

        // Example implementation: return "Value: " + value
        mv.visitLdcInsn("Value: "); // Push "Value: " onto the stack
        mv.visitVarInsn(Opcodes.ILOAD, 1); // Load the integer argument
        mv.visitMethodInsn(Opcodes.INVOKESTATIC, "java/lang/String", "valueOf", "(I)Ljava/lang/String;", false); // Convert
                                                                                                                 // int
                                                                                                                 // to
                                                                                                                 // String
        mv.visitMethodInsn(Opcodes.INVOKEVIRTUAL, "java/lang/String", "concat",
                "(Ljava/lang/String;)Ljava/lang/String;", false); // Concatenate strings

        mv.visitInsn(Opcodes.ARETURN); // Return the string
        mv.visitMaxs(3, 2); // Correct max stack and local variables
        mv.visitEnd();

        cw.visitEnd();

        byte[] bytecode = cw.toByteArray();

        // Optional: Write bytecode to file for inspection with javap -c
        Files.write(Paths.get(className + ".class"), bytecode);

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
        Class<?> generatedClass = classLoader.loadClass(className);

        // Create an instance and use it
        MyInterface instance = (MyInterface) generatedClass.getDeclaredConstructor().newInstance();
        String result = instance.myMethod(42);
        System.out.println(result); // Output: Value: 42

        // Example of using TraceClassVisitor to print out the generated code
        ClassReader cr = new ClassReader(bytecode);
        TraceClassVisitor tcv = new TraceClassVisitor(new PrintWriter(System.out));
        cr.accept(tcv, 0);

    }
}