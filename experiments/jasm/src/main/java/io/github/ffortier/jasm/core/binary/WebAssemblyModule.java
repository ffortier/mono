package io.github.ffortier.jasm.core.binary;

import java.util.List;

public record WebAssemblyModule(
        List<FuncType> types,
        List<Func> funcs,
        List<Table> tables,
        List<Memory> memories,
        List<Global> globals,
        List<Element> elements,
        List<Data> data,
        Start start,
        List<Import> imports,
        List<Export> exports) {
    static class Builder {
        private List<FuncType> _types;
        private List<Func> _funcs;
        private List<Table> _tables;
        private List<Memory> _memories;
        private List<Global> _globals;
        private List<Element> _elements;
        private List<Data> _data;
        private Start _start;
        private List<Import> _imports;
        private List<Export> _exports;

        public void types(List<FuncType> types) {
            _types = types;
        };

        public void funcs(List<Func> funcs) {
            _funcs = funcs;
        };

        public void tables(List<Table> tables) {
            _tables = tables;
        };

        public void memories(List<Memory> memories) {
            _memories = memories;
        };

        public void globals(List<Global> globals) {
            _globals = globals;
        };

        public void elements(List<Element> elements) {
            _elements = elements;
        };

        public void data(List<Data> data) {
            _data = data;
        };

        public void start(Start start) {
            _start = start;
        };

        public void imports(List<Import> imports) {
            _imports = imports;
        };

        public void exports(List<Export> exports) {
            _exports = exports;
        };

        public WebAssemblyModule build() {
            return new WebAssemblyModule(_types, _funcs, _tables, _memories, _globals, _elements, _data, _start,
                    _imports,
                    _exports);
        }
    }

    public static Builder builder() {
        return new Builder();
    }
}
