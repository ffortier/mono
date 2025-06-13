// import { css, html, LitElement } from "lit";
// import { customElement } from "lit/decorators.js";

// @customElement("my-element")
// export class MyElement extends LitElement {
//   override render() {
//     const message = "hello world";
//     return html`<p>${message}</p>`;
//   }
// }

// (async () => {
//   const memory = new WebAssembly.Memory({ initial: 10 });

//   interface DigitalAPI {
//     makeVisitor(): number;

//     make_jk_flip_flop(): number;
//     apply(): void;

//     visitChildren(visitor: number, component: number): void;

//     observableTypeName(observable: number): number;
//     observablePinValue(observable: number, pinIndex: number): number;
//   }

//   const decodeCString = (memory: WebAssembly.Memory, offset: number) => {
//     const buffer = new Uint8Array(memory.buffer, offset);
//     const decoder = new TextDecoder();
//     const len = buffer.findIndex((value) => value === 0);

//     return decoder.decode(buffer.slice(0, len));
//   };

//   const objectRefs: Record<number, unknown> = {};

//   const dispatch = (name: string) => (ref: number, ...args: unknown[]) => {
//     const obj = objectRefs[ref];
//     if (!obj) throw new Error(`Unknown object ref: ${ref}`);
//     return (obj as any)[name](...args);
//   };

//   class Visitor {
//     #self: number;

//     constructor(
//       private readonly api: DigitalAPI,
//       private readonly memory: WebAssembly.Memory,
//     ) {
//       this.#self = this.api.makeVisitor();

//       objectRefs[this.#self] = this;
//     }

//     visitPin(component: number, pinName: number, pinIndex: number) {
//       console.log(
//         "visitPin",
//         decodeCString(this.memory, pinName),
//         this.api.observablePinValue(component, pinIndex),
//       );
//     }

//     visitComponent(component: number) {
//       console.log(
//         "visitComponent",
//         decodeCString(this.memory, this.api.observableTypeName(component)),
//       );

//       this.api.visitChildren(this.#self, component);
//     }
//   }

//   const { instance, module } = await WebAssembly.instantiateStreaming(
//     fetch("/script/digital.wasm"),
//     {
//       env: {
//         memory,
//         dispatchVisitPin: dispatch("visitPin"),
//         dispatchVisitComponent: dispatch("visitComponent"),
//       },
//     },
//   );

//   const api = instance.exports as unknown as DigitalAPI;

//   const visitor = new Visitor(api, memory);
//   const srlatch = api.make_jk_flip_flop();

//   api.apply();

//   visitor.visitComponent(srlatch);
// })();
