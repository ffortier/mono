/// <reference lib="dom" />

export interface Kernel {
    runCell(
        code: string,
        console: HTMLElement,
        params: unknown,
    ): Promise<void>;
}

export abstract class BaseKernel implements Kernel {
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
