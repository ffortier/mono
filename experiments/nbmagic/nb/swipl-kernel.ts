/// <reference lib="dom" />
import { BaseKernel } from "./base-kernel.ts";

declare let SWIPL: (...args: any[]) => any;

export class SwiplKernel extends BaseKernel {
    private swipl: any;
    private readonly bundleURL: URL;

    constructor(resolveURL: (relative: string) => URL) {
        super();
        this.bundleURL = resolveURL("./swipl-bundle.js");
    }

    override makeCommand(
        code: string,
        output: HTMLElement,
        params: unknown,
    ): () => Promise<void> {
        return async () => {
            await this.initSwipl();

            let type = "program";

            if (params && typeof params === "object" && "type" in params) {
                type = params["type"] as string;
            }

            output.innerText = "";

            switch (type) {
                case "program":
                    await this.runProgram(code, output);
                    break;
                case "query":
                    await this.runQuery(code, output);
                    break;
                default:
                    throw new Error(`Unexpected type ${type}`);
            }
        };
    }

    async initSwipl() {
        if (typeof SWIPL === "undefined") {
            await new Promise((resolve) => {
                const s = document.createElement("script");
                s.src = this.bundleURL.toString();
                s.onload = resolve;
                document.body.append(s);
            });
        }

        if (!this.swipl) {
            this.swipl = await SWIPL({ arguments: ["-q"] });
        }
    }

    async runProgram(code: string, output: HTMLElement) {
        if (!output.hasAttribute("nbmagic-program-id")) {
            output.setAttribute(
                "nbmagic-program-id",
                crypto.randomUUID(),
            );
        }

        output.innerText += JSON.stringify(
            await this.swipl.prolog.load_string(
                code,
                output.getAttribute("nbmagic-program-id"),
            ),
        );
    }

    async runQuery(code: string, output: HTMLElement) {
        const query = this.swipl.prolog.query(code);

        let steps = 1;

        for (const bindings of query) {
            output.innerText += JSON.stringify(bindings) + "\n";

            if (--steps) {
                continue;
            }

            steps = await this.prompt(output);

            if (steps <= 0) {
                break;
            }
        }
    }

    async prompt(output: HTMLElement): Promise<number> {
        // TODO: Add buttons for interactions
        await new Promise((resolve) => setTimeout(resolve, 200));
        return 1;
    }
}
