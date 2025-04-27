/// <reference lib="webworker" />
function isEval(data: unknown): data is { type: "eval"; code: string } {
    return !!data && typeof data == "object" && "type" in data &&
        data["type"] == "eval" && "code" in data &&
        typeof data["code"] === "string";
}

addEventListener("message", (e) => {
    const data = e.data;

    if (isEval(data)) {
        const fn = new Function("console", data.code);

        fn({
            log(...args: unknown[]) {
                postMessage({ type: "console.log", args });
            },
        });

        postMessage({ type: "end" });
    }
});
