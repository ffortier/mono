/// <reference lib="webworker" />
globalThis.console = {
    log: (...args) => postMessage({ type: "console.log", args }),
    warn: (...args) => postMessage({ type: "console.warn", args }),
    error: (...args) => postMessage({ type: "console.error", args }),
    info: (...args) => postMessage({ type: "console.info", args }),
} as Console;

function isEval(data: unknown): data is { type: "eval"; code: string } {
    return !!data && typeof data == "object" && "type" in data &&
        data["type"] == "eval" && "code" in data &&
        typeof data["code"] === "string";
}

addEventListener("message", (e) => {
    const data = e.data;

    if (isEval(data)) {
        const promise = globalThis[data.type](`(async () => {${data.code}})()`);

        promise.then(() => {
            postMessage({ type: "end" });
        }, (e: unknown) => {
            postMessage({
                type: "error",
                message: e instanceof Error ? e.message : `${e}`,
            });
        });
    }
});
