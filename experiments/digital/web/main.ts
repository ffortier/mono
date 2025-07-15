const memory = new WebAssembly.Memory({ initial: 10 });

interface DigitalAPI {
  makeVisitor(): number;

  make_jk_flip_flop(): number;
  apply(): void;

  visitChildren(visitor: number, component: number): void;

  observableTypeName(observable: number): number;
  observablePinValue(observable: number, pinIndex: number): number;
}

const decodeCString = (memory: WebAssembly.Memory, offset: number) => {
  const buffer = new Uint8Array(memory.buffer, offset);
  const decoder = new TextDecoder();
  const len = buffer.findIndex((value) => value === 0);

  return decoder.decode(buffer.slice(0, len));
};

const objectRefs: Record<number, unknown> = {};

const dispatch = (name: string) => (ref: number, ...args: unknown[]) => {
  const obj = objectRefs[ref];
  if (!obj) throw new Error(`Unknown object ref: ${ref}`);
  return (obj as any)[name](...args);
};

class Visitor {
  #self: number;

  constructor(
    private readonly api: DigitalAPI,
    private readonly memory: WebAssembly.Memory,
  ) {
    this.#self = this.api.makeVisitor();

    objectRefs[this.#self] = this;
  }

  visitPin(component: number, pinName: number, pinIndex: number) {
    console.log(
      "visitPin",
      decodeCString(this.memory, pinName),
      this.api.observablePinValue(component, pinIndex),
    );
  }

  visitComponent(component: number) {
    console.log(
      "visitComponent",
      decodeCString(this.memory, this.api.observableTypeName(component)),
    );

    this.api.visitChildren(this.#self, component);
  }
}

const wasm = WebAssembly.instantiateStreaming(
  fetch("/script/digital.wasm"),
  {
    env: {
      memory,
      dispatchVisitPin: dispatch("visitPin"),
      dispatchVisitComponent: dispatch("visitComponent"),
    },
  },
);

class DigitalJkFlipFlopElement extends HTMLElement {
  constructor() {
    super();
    const shadowRoot = this.attachShadow({ mode: "open" });

    shadowRoot.append("Open console");
  }

  async connectedCallback() {
    const api = (await wasm).instance.exports as unknown as DigitalAPI;
    const visitor = new Visitor(api, memory);
    const jk = api.make_jk_flip_flop();

    api.apply();

    visitor.visitComponent(jk);
  }
}

customElements.define("digital-jk-flip-flop", DigitalJkFlipFlopElement);
