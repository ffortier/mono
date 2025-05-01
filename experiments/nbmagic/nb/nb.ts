/// <reference lib="dom" />
import { JavascriptKernel } from "./js-kernel.ts";
import { SwiplKernel } from "./swipl-kernel.ts";
import { Kernel } from "./base-kernel.ts";
import "./nb-magic-element.ts";

const resolveURL = (() => {
    const baseURI = document.currentScript?.baseURI ?? document.baseURI;
    const scriptURI = new URL(
        document.currentScript?.getAttribute("src") ?? "../script/nb.js",
        baseURI,
    );

    return (relative: string) => new URL(relative, scriptURI);
})();

const nbmagic = /^\s*%nbmagic:([^\n]*)\n/;

const kernels: Record<string, Kernel> = {};

const getKernel = (name: string) => {
    if (name in kernels) return kernels[name] as Kernel;

    switch (name) {
        case "js":
            return kernels[name] = new JavascriptKernel(resolveURL);
        case "swipl":
            return kernels[name] = new SwiplKernel(resolveURL);
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
