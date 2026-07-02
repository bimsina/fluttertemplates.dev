#!/usr/bin/env node
// Scaffolds new widgets for fluttertemplates.dev.
//
// It creates, idempotently (never overwrites an existing file):
//   - src/content/widgets/<category>/index.md      (category page, if missing)
//   - src/content/widgets/<category>/<name>.md      (widget metadata)
//   - flutter_apps/core/lib/<category>/<name>.dart   (compiling stub screen)
// and injects the matching `import` + `routes` entry into
//   - flutter_apps/core/lib/main.dart
//
// Usage:
//   node scripts/scaffold.mjs --manifest scripts/widgets.manifest.json
//   node scripts/scaffold.mjs <category> <name> "<Title>" --desc "..." [--size mobile|tablet|desktop] [--class ClassName]
//
// `<category>` may contain slashes for nested groups (e.g. must_haves/onboarding_page).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const WIDGETS_DIR = path.join(ROOT, "src/content/widgets");
const LIB_DIR = path.join(ROOT, "flutter_apps/core/lib");
const MAIN_DART = path.join(LIB_DIR, "main.dart");

const pascal = (s) =>
  s
    .split(/[_\-\/]/)
    .filter(Boolean)
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join("");

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function writeIfMissing(file, contents, log) {
  if (fs.existsSync(file)) {
    log.skipped.push(path.relative(ROOT, file));
    return false;
  }
  ensureDir(path.dirname(file));
  fs.writeFileSync(file, contents);
  log.created.push(path.relative(ROOT, file));
  return true;
}

function categoryIndexMd(meta) {
  const lines = ["---", `title: "${meta.title}"`, `description: "${meta.description}"`];
  if (meta.order != null) lines.push(`order: ${meta.order}`);
  if (meta.icon) lines.push(`icon: ${meta.icon}`);
  lines.push("---", "");
  return lines.join("\n");
}

function widgetMd(w) {
  const lines = [
    "---",
    `title: ${w.title}`,
    `description: ${w.description}`,
    "app: core",
    `path: /${w.category}/${w.name}`,
    `code_files: ["${w.category}/${w.name}.dart"]`,
  ];
  if (w.size && w.size !== "mobile") lines.push(`previewSize: ${w.size}`);
  lines.push("---", "");
  return lines.join("\n");
}

function dartStub(className, title) {
  return `import 'package:flutter/material.dart';

class ${className} extends StatelessWidget {
  const ${className}({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${title.replace(/'/g, "\\'")}')),
      body: const Center(child: Text('${title.replace(/'/g, "\\'")}')),
    );
  }
}
`;
}

function injectIntoMain(w, className, log) {
  let src = fs.readFileSync(MAIN_DART, "utf8");
  const importStmt = `import '${w.category}/${w.name}.dart';`;
  const routeKey = `"/${w.category}/${w.name}"`;
  let changed = false;

  // Insert import right before `void main()` if not present.
  if (!src.includes(importStmt)) {
    const anchor = "\nvoid main() {";
    const idx = src.indexOf(anchor);
    if (idx === -1) throw new Error("Could not find `void main()` in main.dart");
    src = src.slice(0, idx) + `\n${importStmt}` + src.slice(idx);
    changed = true;
  }

  // Insert route entry before the closing `};` of the routes map.
  if (!src.includes(routeKey + ":")) {
    const mapStart = src.indexOf("final routes = <String, Widget Function()>{");
    if (mapStart === -1) throw new Error("Could not find routes map in main.dart");
    const closeIdx = src.indexOf("\n};", mapStart);
    if (closeIdx === -1) throw new Error("Could not find end of routes map in main.dart");
    const entry = `  ${routeKey}: () => const ${className}(),\n`;
    src = src.slice(0, closeIdx + 1) + entry + src.slice(closeIdx + 1);
    changed = true;
  }

  if (changed) {
    fs.writeFileSync(MAIN_DART, src);
    log.mainDartRoutes.push(`${routeKey} -> ${className}`);
  }
  return changed;
}

function scaffoldOne(w, categories, log) {
  const className = w.cls || pascal(w.name);

  // Category index.md
  const catDir = path.join(WIDGETS_DIR, w.category);
  const indexFile = path.join(catDir, "index.md");
  if (!fs.existsSync(indexFile)) {
    const meta = categories[w.category];
    if (meta) {
      writeIfMissing(indexFile, categoryIndexMd(meta), log);
    } else {
      log.warnings.push(`No category meta for "${w.category}" and no existing index.md`);
    }
  }

  writeIfMissing(path.join(catDir, `${w.name}.md`), widgetMd(w), log);
  writeIfMissing(path.join(LIB_DIR, w.category, `${w.name}.dart`), dartStub(className, w.title), log);
  injectIntoMain(w, className, log);
}

function run() {
  const args = process.argv.slice(2);
  const log = { created: [], skipped: [], mainDartRoutes: [], warnings: [] };

  const manifestIdx = args.indexOf("--manifest");
  if (manifestIdx !== -1) {
    const manifestPath = path.resolve(ROOT, args[manifestIdx + 1]);
    const { categories = {}, widgets = [] } = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
    for (const w of widgets) scaffoldOne(w, categories, log);
  } else {
    // Single mode: <category> <name> "<Title>"
    const [category, name, title] = args;
    if (!category || !name || !title) {
      console.error('Usage: node scripts/scaffold.mjs <category> <name> "<Title>" --desc "..." [--size ...] [--class ...]');
      process.exit(1);
    }
    const get = (flag) => {
      const i = args.indexOf(flag);
      return i !== -1 ? args[i + 1] : undefined;
    };
    scaffoldOne(
      {
        category,
        name,
        title,
        description: get("--desc") || title,
        size: get("--size") || "mobile",
        cls: get("--class"),
      },
      {},
      log,
    );
  }

  console.log(`\n✅ Created ${log.created.length} files:`);
  log.created.forEach((f) => console.log("   +", f));
  if (log.mainDartRoutes.length) {
    console.log(`\n🔗 Injected ${log.mainDartRoutes.length} routes into main.dart`);
  }
  if (log.skipped.length) console.log(`\n⏭️  Skipped ${log.skipped.length} existing files`);
  if (log.warnings.length) {
    console.log(`\n⚠️  Warnings:`);
    log.warnings.forEach((wn) => console.log("   -", wn));
  }
  console.log("");
}

run();
