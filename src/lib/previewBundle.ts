import fs from "node:fs";
import path from "node:path";

// scripts/build.js fingerprints the Flutter bundles, so the wasm file name is
// only known from the build config in flutter_bootstrap.js.
export function previewWasmUrl(app = "core"): string | null {
  const bootstrap = path.join(
    process.cwd(),
    "public",
    "flutter_apps",
    app,
    "flutter_bootstrap.js",
  );
  if (!fs.existsSync(bootstrap)) return null;

  const match = fs
    .readFileSync(bootstrap, "utf8")
    .match(/"mainWasmPath":"([^"]+)"/);
  return match ? `/flutter_apps/${app}/${match[1]}` : null;
}
