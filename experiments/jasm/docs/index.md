# Jasm

Java JIT/AOT compiler for Web Assembly

## Usage

```shell
jasm aot -o test.jar -c com.example.MyProgram test.wasm
jasm interface -o com/example/MyProgram.java -c com.example.MyProgram test.wasm
```

```java
import io.github.ffortier.jasm.JIT;

class Main {
    interface MyProgram {
        String hello();
    }

    public static void main(String[] args) {
        final var program = JIT.compileAndInstantiate(args[0], MyProgram.class);

        System.out.println(program.hello());
    }
}
```