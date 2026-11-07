#!/usr/bin/env node
// Generates everything derived from the widget library, from one pass over the
// content and the Dart source:
//   src/generated/widget_meta.json  per-widget facts used by the Astro pages
//   public/r/index.json             searchable catalogue (CLI, MCP, tools)
//   public/r/<id>.json              one widget, with its files and dependencies
//   public/r/<id>.md                the same widget as Markdown, for LLMs
//   public/r/LICENSE                the notice copied code has to carry
//   public/llms.txt                 index of the library for LLMs
// All of it is gitignored and rebuilt by `pnpm dev` and `pnpm build`.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const WIDGETS_DIR = path.join(ROOT, "src/content/widgets");
const TEMPLATES_DIR = path.join(ROOT, "src/content/templates");
const LIB_DIR = path.join(ROOT, "flutter_apps/core/lib");
const PUBSPEC = path.join(ROOT, "flutter_apps/core/pubspec.yaml");
const GENERATED_DIR = path.join(ROOT, "src/generated");
const REGISTRY_DIR = path.join(ROOT, "public/r");
const SITE = "https://fluttertemplates.dev";
const REGISTRY_VERSION = 1;
// Every entry declares its license, so that the notice can travel with the code.
const LICENSE = { license: "MIT", licenseUrl: `${SITE}/r/LICENSE` };

// Flutter widgets worth surfacing on a page. Layout noise such as Padding or
// SizedBox is left out on purpose: it would make every page look the same.
const NOTABLE_WIDGETS = new Set(
  `AbsorbPointer AlertDialog AnimatedBuilder AnimatedContainer AnimatedCrossFade
  AnimatedList AnimatedOpacity AnimatedPositioned AnimatedSize AnimatedSwitcher
  AppBar Autocomplete Badge BottomAppBar BottomNavigationBar BottomSheet Card
  CheckboxListTile Checkbox Chip ChoiceChip CircleAvatar
  CircularProgressIndicator ClipPath ClipRRect CupertinoActionSheet
  CupertinoAlertDialog CupertinoButton CupertinoDatePicker CupertinoNavigationBar
  CupertinoPicker CupertinoSlidingSegmentedControl CupertinoSwitch
  CupertinoTabBar CustomPaint CustomScrollView DataTable DatePickerDialog
  DateRangePickerDialog DefaultTabController Dialog Dismissible DraggableScrollableSheet
  Draggable DragTarget Drawer DropdownButton DropdownButtonFormField DropdownMenu
  ElevatedButton ExpansionPanelList ExpansionTile FadeTransition FilledButton
  FilterChip FloatingActionButton Form FutureBuilder GestureDetector GridView
  Hero IconButton Image IndexedStack InkWell InputChip InteractiveViewer
  LayoutBuilder LinearProgressIndicator ListTile ListView ListWheelScrollView
  MediaQuery MenuAnchor ModalBarrier NavigationBar NavigationDrawer NavigationRail
  NestedScrollView OutlinedButton PageView PopupMenuButton PositionedTransition
  RadioListTile Radio RangeSlider RefreshIndicator ReorderableListView RichText
  RotationTransition SafeArea ScaleTransition Scrollbar SearchAnchor SearchBar
  SegmentedButton SelectableText ShaderMask SimpleDialog SingleChildScrollView
  SlideTransition Slider SliverAppBar SliverGrid SliverList SliverPersistentHeader
  SnackBar Stepper StreamBuilder Switch SwitchListTile TabBar TabBarView Table
  TextButton TextField TextFormField Tooltip TweenAnimationBuilder Visibility
  Wrap`.split(/\s+/),
);

function parseFrontmatter(source) {
  const match = source.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return {};
  const data = {};
  for (const line of match[1].split("\n")) {
    const pair = line.match(/^([a-zA-Z_]+):\s*(.*)$/);
    if (!pair) continue;
    const [, key, raw] = pair;
    const value = raw.trim();
    if (value.startsWith("[")) data[key] = JSON.parse(value);
    else data[key] = value.replace(/^(["'])(.*)\1$/, "$2");
  }
  return data;
}

function listMarkdown(dir) {
  return fs
    .readdirSync(dir, { recursive: true, withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith(".md"))
    .map((entry) => path.join(entry.parentPath, entry.name))
    .sort();
}

function hostedVersions() {
  const versions = {};
  const section = fs
    .readFileSync(PUBSPEC, "utf8")
    .match(/^dependencies:\n([\s\S]*?)^\S/m);
  for (const line of (section?.[1] ?? "").split("\n")) {
    const pair = line.match(/^  ([a-z0-9_]+):\s*(\S+)\s*$/);
    if (pair) versions[pair[1]] = pair[2];
  }
  return versions;
}

function analyze(source, versions) {
  const declared = new Set(
    [...source.matchAll(/\bclass\s+([A-Za-z0-9_]+)/g)].map((m) => m[1]),
  );
  const used = new Set();
  for (const [, name] of source.matchAll(/\b([A-Z][A-Za-z0-9]+)(?:<[^()]*>)?(?:\.[a-z]\w*)?\(/g)) {
    if (NOTABLE_WIDGETS.has(name) && !declared.has(name)) used.add(name);
  }
  const packages = new Set();
  for (const [, name] of source.matchAll(/^import\s+'package:([a-z0-9_]+)\//gm)) {
    if (name !== "flutter" && name !== "core") packages.add(name);
  }
  return {
    flutterWidgets: [...used].sort(),
    dependencies: [...packages]
      .sort()
      .map((name) => ({ name, version: versions[name] ?? "any" })),
  };
}

function loadWidgets() {
  const versions = hostedVersions();
  const categories = new Map();
  const widgets = [];

  for (const file of listMarkdown(WIDGETS_DIR)) {
    const id = path
      .relative(WIDGETS_DIR, file)
      .replace(/\.md$/, "")
      .replace(/\/index$/, "");
    const data = parseFrontmatter(fs.readFileSync(file, "utf8"));
    if (file.endsWith("/index.md")) {
      categories.set(id, data.title ?? id);
      continue;
    }
    if (!data.path || !data.code_files) continue;

    const files = data.code_files.map((codeFile) => ({
      path: codeFile,
      content: fs.readFileSync(path.join(LIB_DIR, codeFile), "utf8"),
    }));
    const source = files.map((f) => f.content).join("\n");
    widgets.push({
      id,
      title: data.title,
      description: data.description ?? "",
      category: id.split("/")[0],
      url: `${SITE}/widgets/${id}/`,
      ...LICENSE,
      previewPath: data.path,
      loc: source.split("\n").length,
      files,
      ...analyze(source, versions),
    });
  }

  for (const widget of widgets) {
    widget.categoryTitle = categories.get(widget.category) ?? widget.category;
  }
  return widgets;
}

// Templates that run in the core app. Their files keep relative imports, so the
// folder can be copied into any project as is.
function loadTemplates() {
  const versions = hostedVersions();
  const templates = [];
  for (const file of listMarkdown(TEMPLATES_DIR)) {
    const data = parseFrontmatter(fs.readFileSync(file, "utf8"));
    if (!data.code_dir) continue;
    const dir = path.join(LIB_DIR, data.code_dir);
    const files = fs
      .readdirSync(dir, { recursive: true, withFileTypes: true })
      .filter((entry) => entry.isFile() && entry.name.endsWith(".dart"))
      .map((entry) => path.join(entry.parentPath, entry.name))
      .sort()
      .map((dartFile) => ({
        path: path.relative(LIB_DIR, dartFile),
        content: fs.readFileSync(dartFile, "utf8"),
      }));
    const slug = path.basename(file, ".md");
    const source = files.map((f) => f.content).join("\n");
    templates.push({
      id: `templates/${slug}`,
      title: data.title,
      description: data.description ?? "",
      category: "templates",
      categoryTitle: "Full apps",
      url: `${SITE}/templates/${slug}/`,
      ...LICENSE,
      previewPath: data.path,
      loc: source.split("\n").length,
      files,
      ...analyze(source, versions),
    });
  }
  return templates;
}

// Same category counts for more than shared widgets, and sharing a very common
// widget says little, so each shared widget is weighted by how rare it is.
function relatedWidgets(widgets) {
  const frequency = new Map();
  for (const w of widgets) {
    for (const name of w.flutterWidgets) {
      frequency.set(name, (frequency.get(name) ?? 0) + 1);
    }
  }
  const related = new Map();
  for (const widget of widgets) {
    const own = new Set(widget.flutterWidgets);
    const scored = widgets
      .filter((other) => other.id !== widget.id)
      .map((other) => {
        let score = other.category === widget.category ? 3 : 0;
        for (const name of other.flutterWidgets) {
          if (own.has(name)) score += 1 / Math.log2(1 + frequency.get(name));
        }
        return { other, score };
      })
      .sort((a, b) => b.score - a.score || a.other.id.localeCompare(b.other.id));
    related.set(
      widget.id,
      scored.slice(0, 6).map(({ other }) => ({
        id: other.id,
        title: other.title,
        category: other.categoryTitle,
      })),
    );
  }
  return related;
}

function writeFile(file, contents) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, contents);
}

function widgetMarkdown(widget) {
  const lines = [
    `# Flutter ${widget.title}`,
    "",
    widget.description,
    "",
    `- Page and live preview: ${widget.url}`,
    `- Add it: \`fluttertemplates add ${widget.id}\``,
    `- License: ${widget.license} (${widget.licenseUrl}). Keep this notice with copied code.`,
  ];
  if (widget.dependencies.length) {
    lines.push(
      `- Packages: ${widget.dependencies.map((d) => d.name).join(", ")}`,
    );
  }
  for (const file of widget.files) {
    lines.push("", `## ${file.path}`, "", "```dart", file.content.trimEnd(), "```");
  }
  return lines.join("\n") + "\n";
}

function llmsTxt(widgets) {
  const byCategory = new Map();
  for (const widget of widgets) {
    if (!byCategory.has(widget.categoryTitle)) {
      byCategory.set(widget.categoryTitle, []);
    }
    byCategory.get(widget.categoryTitle).push(widget);
  }
  const lines = [
    "# Flutter Templates",
    "",
    "> Open-source Flutter screens with live previews. Every entry is a single, dependency-light Dart file under the MIT license.",
    "",
    `Machine-readable catalogue: ${SITE}/r/index.json. Each widget is also available at ${SITE}/r/<id>.json and ${SITE}/r/<id>.md.`,
  ];
  for (const [title, items] of [...byCategory].sort(([a], [b]) => a.localeCompare(b))) {
    lines.push("", `## ${title}`, "");
    for (const w of items) {
      lines.push(`- [${w.title}](${SITE}/r/${w.id}.md): ${w.description}`);
    }
  }
  return lines.join("\n") + "\n";
}

const widgets = loadWidgets();
const related = relatedWidgets(widgets);
const templates = loadTemplates();

fs.rmSync(REGISTRY_DIR, { recursive: true, force: true });

const meta = {};
for (const w of widgets) {
  meta[w.id] = {
    loc: w.loc,
    flutterWidgets: w.flutterWidgets,
    dependencies: w.dependencies,
    related: related.get(w.id),
  };
  const { files, ...summary } = w;
  writeFile(
    path.join(REGISTRY_DIR, `${w.id}.json`),
    JSON.stringify({ ...summary, files }, null, 2) + "\n",
  );
  writeFile(path.join(REGISTRY_DIR, `${w.id}.md`), widgetMarkdown(w));
}

for (const t of templates) {
  writeFile(
    path.join(REGISTRY_DIR, `${t.id}.json`),
    JSON.stringify(t, null, 2) + "\n",
  );
  writeFile(path.join(REGISTRY_DIR, `${t.id}.md`), widgetMarkdown(t));
}

writeFile(
  path.join(GENERATED_DIR, "widget_meta.json"),
  JSON.stringify(meta, null, 2) + "\n",
);
writeFile(
  path.join(REGISTRY_DIR, "index.json"),
  JSON.stringify(
    {
      version: REGISTRY_VERSION,
      ...LICENSE,
      widgets: [...widgets, ...templates].map(({ files, ...summary }) => ({
        ...summary,
        files: files.map((f) => f.path),
      })),
    },
    null,
    2,
  ) + "\n",
);
fs.copyFileSync(path.join(ROOT, "LICENSE"), path.join(REGISTRY_DIR, "LICENSE"));
writeFile(path.join(ROOT, "public/llms.txt"), llmsTxt([...widgets, ...templates]));

console.log(`Registry: ${widgets.length} widgets, ${templates.length} templates`);
