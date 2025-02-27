package io.github.ffortier.jasm.core.binary;

import java.util.List;

public record Func(
                Index.TypeIdx type,
                List<Locals> locals,
                Expr body) {
}
