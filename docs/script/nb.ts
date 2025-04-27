/// <reference lib="dom" />

import { run } from "../../modules/uxn/examples/app.js";
import { inherits } from "../../site/assets/javascripts/lunr/wordcut.js";
const src = document.currentScript?.getAttribute("src");
const a = new URL(src!, document.currentScript?.baseURI);
const b = new URL("./js-kernel.js", a);

const nbmagic = /^(?:\s|\n|\r)*%nbmagic:([^\n]*)\n/;

interface Stream {
    write(s: string): Promise<void>;
}

interface Kernel {
    init(params: unknown): void;
    runCell(code: HTMLElement, console: HTMLElement): Promise<void>;
}

class JavascriptKernel implements Kernel {
    private worker: Worker;
    constructor() {
        this.worker = new Worker(b);
    }
    init(params: unknown): void {
    }

    async runCell(
        code: HTMLElement,
        console: HTMLElement,
    ): Promise<void> {
        code.classList.add("running");
        console.innerText = "";

        const handler = (e: MessageEvent) => {
            switch (e.data.type) {
                case "console.log":
                    console.innerText += (e.data.args as unknown[]).join(" ") +
                        "\n";
                    break;
                case "end":
                    this.worker.removeEventListener("message", handler);
                    code.classList.remove("running");
                    break;
            }
        };

        this.worker.addEventListener("message", handler);

        this.worker.postMessage({ type: "eval", code: code.innerText });
    }
}

const kernels = { "js": new JavascriptKernel() } as const;

for (const code of Array.from(document.querySelectorAll("code"))) {
    const m = nbmagic.exec(code.innerText);

    if (m) {
        code.contentEditable = "plaintext-only";
        code.innerText = code.innerText.substring(m[0].length);
        code.classList.add("nbmagic");

        const consoleElement = document.createElement("code");
        consoleElement.classList.add("nbmagic-console");

        code.parentElement?.append(
            document.createElement("span"),
            consoleElement,
        );
        const { kernel, ...params } = JSON.parse(m[1]);

        const k = kernels[kernel as keyof typeof kernels];

        k.init(params);

        code.parentElement?.addEventListener(
            "click",
            async (e) => {
                if (e.currentTarget == e.target) {
                    await k.runCell(code, consoleElement);
                }
            },
        );
    }
}
