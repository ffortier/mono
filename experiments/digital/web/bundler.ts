import * as esbuild from "esbuild/wasm.js";
import { denoPlugins } from "@luca/esbuild-deno-loader";

let outfile: string | null = null;
const entryPoints: string[] = [];

for (let i = 0; i < Deno.args.length; i++) {
  if (Deno.args[i] === "-o") {
    outfile = Deno.args[++i];
  } else {
    entryPoints.push(Deno.args[i]);
  }
}

if (!outfile) throw new Error("Missing outfile");
if (!entryPoints.length) throw new Error("Missing entry points");

const result = await esbuild.build({
  plugins: [...denoPlugins()],
  entryPoints,
  outfile,
  bundle: true,
  format: "esm",
});

await esbuild.stop();

for (const err of result.errors) {
  console.error(err);
}
