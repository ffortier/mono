class Gol64CanvasElement extends HTMLElement {
    static wasmModule = null;

    wasmInstance = null;
    wasmMemory = null;
    animationFrameId = null;

    constructor() {
        super();
        this.style.display = 'block';

        const root = this.attachShadow({ mode: 'open' });

        root.innerHTML = `<canvas width="${8 * 40}" height="${8 * 25}"></canvas>`;

        if (!Gol64CanvasElement.wasmModule) {
            Gol64CanvasElement.wasmModule = fetch('/script/gol64.wasm')
                .then(response => response.arrayBuffer())
                .then(bytes => WebAssembly.compile(bytes, {}))
                .then(results => Gol64CanvasElement.wasmModule = results);
        }

        this.wasmMemory = new WebAssembly.Memory({ initial: 256, maximum: 256 });
        this.wasmInstance = Promise.resolve(Gol64CanvasElement.wasmModule)
            .then(module => new WebAssembly.Instance(module, { env: { memory: this.wasmMemory } }))
            .then(instance => this.init(instance));
    }

    init(instance) {
        this.wasmInstance = instance;

        instance.exports.init_mem(instance.exports.glider_gun, 9);

        if (this.isConnected) {
            this.startAnimation(instance);
        }
    }

    connectedCallback() {
        if (this.wasmInstance instanceof WebAssembly.Instance) {
            this.startAnimation(this.wasmInstance);
        }
    }

    disconnectedCallback() {
        clearTimeout(this.animationFrameId);
    }

    startAnimation(instance) {
        const canvas = this.shadowRoot.querySelector('canvas');
        const ctx = canvas.getContext('2d');
        const mem = new Uint8Array(this.wasmMemory.buffer, instance.exports.mem, 1000);

        const frame = () => {
            instance.exports.update_cells();

            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.fillStyle = 'black';

            for (let y = 0; y < 25; y++) {
                for (let x = 0; x < 40; x++) {
                    const cell = mem[y * 40 + x];
                    ctx.beginPath();

                    switch (cell) {
                        case 81: ctx.arc(x * 8 + 4, y * 8 + 4, 4, 0, 2 * Math.PI); break;
                        case 32: break;
                        default: throw new Error(`Unknown cell value: ${cell}`);
                    }

                    ctx.fill();
                    ctx.closePath();
                }
            };


            if (this.isConnected) {
                this.animationFrameId = setTimeout(frame, 500);
            }
        }

        this.animationFrameId = setTimeout(frame, 500);
    }
}

customElements.define('gol64-canvas', Gol64CanvasElement);