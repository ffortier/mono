import { createEmulator } from 'uxn5';

const emulator = createEmulator();
const target_fps = 60;

await emulator.init();

emulator.console.write_el = document.getElementById("console_out");
emulator.console.error_el = document.getElementById("console_err")
emulator.bgCanvas = document.getElementById("bgcanvas");
emulator.fgCanvas = document.getElementById("fgcanvas");
emulator.screen.bgctx = emulator.bgCanvas.getContext("2d", { "willReadFrequently": true })
emulator.screen.fgctx = emulator.fgCanvas.getContext("2d", { "willReadFrequently": true })
document.getElementById("screen").addEventListener("pointermove", emulator.pointer_moved)
document.getElementById("screen").addEventListener("pointerdown", emulator.pointer_down)
document.getElementById("screen").addEventListener("pointerup", emulator.pointer_up)
window.addEventListener("keydown", emulator.controller.keyevent);
window.addEventListener("keyup", emulator.controller.keyevent);

// Console Input Field
const console_input = document.getElementById("console_input")
console_input.addEventListener("keyup", function (event) {
    if (event.key === "Enter") {
        let query = console_input.value
        for (let i = 0; i < query.length; i++)
            emulator.console.input(query.charAt(i).charCodeAt(0), 1)
        emulator.console.input(0x0a, 1)
        console_input.value = ""
    }
});

// Animation callback
function step() {
    emulator.screen_callback();
}

emulator.screen.set_size(512, 320);

setInterval(() => {
    window.requestAnimationFrame(step);
}, 1000 / target_fps);

export function run(rom) {
    emulator.bgCanvas.style.width = '';
    emulator.uxn.load(rom).eval(0x0100);
}