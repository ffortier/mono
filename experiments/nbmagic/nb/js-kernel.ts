/// <reference lib="dom" />
import { BaseKernel } from "./base-kernel.ts";

export class JavascriptKernel extends BaseKernel {
    private worker: Worker;

    constructor(resolveURL: (relative: string) => URL) {
        super();
        this.worker = new Worker(resolveURL("./js-worker.js"));
    }

    override makeCommand(
        code: string,
        output: HTMLElement,
        _params: unknown,
    ): () => Promise<void> {
        return () =>
            new Promise<void>((resolve, reject) => {
                output.innerText = "";

                const handler = (e: MessageEvent) => {
                    switch (e.data.type) {
                        case "console.log":
                        case "console.info":
                        case "console.warn":
                        case "console.error":
                            output.innerText +=
                                (e.data.args as unknown[]).join(" ") +
                                "\n";
                            break;
                        case "end":
                            this.worker.removeEventListener("message", handler);
                            resolve();
                            break;
                        case "error":
                            this.worker.removeEventListener("message", handler);
                            reject(e.data.message);
                            break;
                    }
                };

                this.worker.addEventListener("message", handler);

                this.worker.postMessage({ type: "eval", code });
            });
    }
}
