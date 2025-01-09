/** Generated with jasm */
package io.github.ffortier.jasm.examples.adder;

import java.nio.ByteBuffer;

public interface Adder {
    ByteBuffer memory();

    int add(int arg0, int arg1);
}