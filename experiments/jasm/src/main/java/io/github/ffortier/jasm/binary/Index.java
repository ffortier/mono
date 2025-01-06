package io.github.ffortier.jasm.binary;

public sealed interface Index permits
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

    record TypeIdx(int value) implements Index {
    }

    record FuncIdx(int value) implements Index {
    }

    record TableIdx(int value) implements Index {
    }

    record MemIdx(int value) implements Index {
    }

    record GlobalIdx(int value) implements Index {
    }

    record ElemIdx(int value) implements Index {
    }

    record DataIdx(int value) implements Index {
    }

    record LocalIdx(int value) implements Index {
    }

    record LabelIdx(int value) implements Index {
    }
}
