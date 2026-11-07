#!/usr/bin/env node
// Adds screens to the preview app. Each input line is
// `/route|relative/file.dart|ClassName`. Lines already present are skipped.
//   node scripts/add-routes.mjs routes.txt [more.txt]

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const MAIN_DART = path.join(ROOT, "flutter_apps/core/lib/main.dart");

let source = fs.readFileSync(MAIN_DART, "utf8");
const added = [];

for (const file of process.argv.slice(2)) {
  for (const line of fs.readFileSync(file, "utf8").split("\n")) {
    if (!line.trim()) continue;
    const [route, dartFile, className] = line.trim().split("|");
    if (source.includes(`'${route}':`) || source.includes(`"${route}":`)) continue;

    const importLine = `import '${dartFile}';\n`;
    if (!source.includes(importLine)) {
      source = source.replace("\nvoid main()", `\n${importLine}void main()`);
    }
    source = source.replace(
      /(final routes = <String, Widget Function\(\)>\{\n)/,
      `$1  '${route}': () => const ${className}(),\n`,
    );
    added.push(route);
  }
}

fs.writeFileSync(MAIN_DART, source);
console.log(`Added ${added.length} routes`);
