/// <reference lib="dom" />
const resolveURL = (() => {
    const baseURI = document.currentScript?.baseURI ?? document.baseURI;
    const scriptURI = new URL(
        document.currentScript?.getAttribute("src") ?? "../script/nb.js",
        baseURI,
    );

    return (relative: string) => new URL(relative, scriptURI);
})();

const nbmagic = /^\s*%nbmagic:([^\n]*)\n/;

interface Stream {
    write(s: string): Promise<void>;
}

interface Kernel {
    runCell(
        code: string,
        console: HTMLElement,
        params: unknown,
    ): Promise<void>;
}

abstract class BaseKernel implements Kernel {
    private commands: [
        () => Promise<void>,
        () => void,
        (err: Error) => void,
    ][] = [];
    private running = false;

    defer(): [Promise<void>, () => void, (err: Error) => void] {
        let resolver: () => void;
        let rejector: (err: Error) => void;

        const promise = new Promise<void>((resolve, reject) => {
            resolver = resolve;
            rejector = reject;
        });

        return [promise, resolver!, rejector!];
    }

    next() {
        const command = this.commands.shift();

        if (command) {
            const [fn, resolver, rejector] = command;

            this.run(fn).then(resolver, rejector);
        } else {
            this.running = false;
        }
    }

    async run(fn: () => Promise<void>): Promise<void> {
        this.running = true;

        try {
            await fn();

            this.next();
        } catch (err) {
            this.running = false;
            this.commands.length = 0;
            return Promise.reject(err);
        }
    }

    abstract makeCommand(
        code: string,
        output: HTMLElement,
        params: unknown,
    ): () => Promise<void>;

    runCell(
        code: string,
        console: HTMLElement,
        params: unknown,
    ): Promise<void> {
        const fn = this.makeCommand(code, console, params);

        if (!this.running) {
            return this.run(fn);
        }

        const [promise, resolver, rejector] = this.defer();

        this.commands.push([fn, resolver, rejector]);

        return promise;
    }
}

class JavascriptKernel extends BaseKernel {
    private worker: Worker;

    constructor() {
        super();
        this.worker = new Worker(resolveURL("./js-kernel.js"));
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

const kernels: Record<string, Kernel> = {};

const getKernel = (name: string) => {
    if (name in kernels) return kernels[name] as Kernel;

    switch (name) {
        case "js":
            return kernels[name] = new JavascriptKernel();
        default:
            throw new Error(`unknown kernel ${name}`);
    }
};

const autoplay = !!document.querySelector("nb-magic[autoplay]");

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

        const k = getKernel(kernel);

        code.parentElement?.addEventListener(
            "click",
            (e) => {
                e.preventDefault();

                if (e.currentTarget == e.target) {
                    code.classList.add("running");
                    k.runCell(code.innerText, consoleElement, params).then(
                        () => code.classList.remove("running"),
                        () => code.classList.remove("running"),
                    );
                }
            },
        );

        if (autoplay) {
            code.classList.add("running");
            k.runCell(code.innerText, consoleElement, params).then(
                () => code.classList.remove("running"),
                () => code.classList.remove("running"),
            );
        }
    }
}

class NbMagicElement extends HTMLElement {
    static observedAttributes = ["controls", "autoplay"] as const;

    constructor() {
        super();
        const shadow = this.attachShadow({ mode: "open" });

        const style = this.ownerDocument.createElement("style");

        style.textContent = `:host { display: block; }`;

        const restartButton = this.ownerDocument.createElement("button");
        restartButton.type = "button";
        restartButton.append("Restart");

        const runAllButton = this.ownerDocument.createElement("button");
        runAllButton.type = "button";
        runAllButton.append("Run All");

        shadow.append(style, restartButton, runAllButton);
    }

    attributeChangedCallback(
        name: typeof NbMagicElement.observedAttributes[number],
        _oldValue: string | undefined,
        newValue: string | undefined,
    ) {
        console.log(name, newValue, typeof newValue);
    }
}

customElements.define("nb-magic", NbMagicElement);
