package io.github.ffortier.jasm.core.binary;

import java.util.List;

public sealed interface Index<T> permits
        Index.TypeIdx,
        Index.FuncIdx,
        Index.TableIdx,
        Index.MemIdx,
        Index.GlobalIdx,
        Index.ElemIdx,
        Index.DataIdx,
        Index.LocalIdx,
        Index.LabelIdx {
    int value();

    default T get(List<? extends T> list) {
        return list.get(value());
    }

    record TypeIdx(int value) implements Index<FuncType> {
    }

    record FuncIdx(int value) implements Index<Func> {
    }

    record TableIdx(int value) implements Index<Table> {
    }

    record MemIdx(int value) implements Index<Memory> {
    }

    record GlobalIdx(int value) implements Index<Global> {
    }

    record ElemIdx(int value) implements Index<Element> {
    }

    record DataIdx(int value) implements Index<Data> {
    }

    record LocalIdx(int value) implements Index<Locals> {
    }

    record LabelIdx(int value) implements Index<Void> {
    }
}
