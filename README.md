# Flutter Templates

Flutter Templates is a curated library of Flutter UI patterns that you can browse, run, and learn from.

It is built for developers who want to move faster when building mobile apps: instead of starting every screen from scratch, you can explore ready-made widgets and full template ideas, then adapt the code to your own project.

Live website: [fluttertemplates.dev](https://fluttertemplates.dev/)

## What You Can Do Here

- Browse Flutter widgets by category (forms, ecommerce, dashboard, navigation, and more)
- Open each widget page and view a runnable preview
- Switch between preview and source code
- Explore full app templates with screenshots and source/demo links
- Use search to find components quickly

## Project Overview

This repository contains two connected parts:

- Website and content app (Astro): `src/`
- Flutter source app for previews: `flutter_apps/core/`

In simple terms:

1. The website renders content from Markdown.
2. Widget pages embed the Flutter web app in an iframe.
3. The iframe gets a `path` query parameter and loads the matching Flutter screen.

## Quick Start

### Prerequisites

- Node.js (LTS recommended)
- `pnpm` (this repo uses `pnpm@10`)
- Flutter SDK (required for running/building widget previews)

### Install

```bash
pnpm install
```

### Run locally (full experience)

Run these in two terminals:

```bash
pnpm dev
```

```bash
pnpm run-apps
```

- `pnpm dev` starts the Astro site.
- `pnpm run-apps` starts the Flutter web app on port `8989` for live iframe previews.

If you run only `pnpm dev`, pages still load, but widget previews will not work in dev mode.

## Technical Details

### Main Commands

- `pnpm dev`: start Astro dev server
- `pnpm run-apps`: run Flutter core app in browser (`--web-port 8989`)
- `pnpm build`: build Astro site
- `pnpm build-apps`: build Flutter web app(s) and copy output to `public/flutter_apps/*`
- `pnpm preview`: preview built Astro output
- `pnpm deploy`: build + deploy with Wrangler
- `pnpm format`: format `src/` with Prettier

### Content Model

Content is powered by Astro collections in `src/content.config.ts`.

#### Widgets

Location: `src/content/widgets/**`

Common frontmatter fields:

- `title`
- `description`
- `app` (currently `core`)
- `path` (Flutter route used by iframe, e.g. `/ecommerce/product_grid`)
- `previewSize` (`mobile`, `tablet`, `desktop`)
- `code_files` (paths relative to `flutter_apps/core/lib/`)
- `order`, `icon` (for grouping/navigation)

Example:

```md
---
title: Product Grid
description: Responsive grid of product cards
app: core
path: /ecommerce/product_grid
code_files: ["ecommerce/product_grid.dart"]
previewSize: mobile
---
```

Validation rules for `code_files` are enforced (no absolute paths, `..`, wildcards, or trailing slash).

#### Templates

Location: `src/content/templates/**`

Common frontmatter fields:

- `title`
- `description`
- `type` (`micro-interaction`, `full-app`, `ui-kit`, `single-page`, `clone`)
- `heroImage`, `appImages`
- `githubUrl`, `demoUrl`, `youtubeVideoId`
- `tags`

### How Widget Previews Work

- Widget pages are generated from `src/pages/widgets/[...slug].astro`.
- The page loads source code from `flutter_apps/<app>/lib/*` based on `code_files`.
- The preview iframe points to:
  - dev: `http://localhost:8989/?path=<widget-path>&theme=<theme>`
  - production: `/flutter_apps/<app>/index.html?path=<widget-path>&theme=<theme>`
- Flutter route mapping lives in `flutter_apps/core/lib/main.dart` (`routes` map).

When adding a new widget, make sure:

1. You add the Dart screen file.
2. You register its `path` in `flutter_apps/core/lib/main.dart`.
3. You create/update the widget markdown entry with matching `path` and `code_files`.

## Project Structure

- `src/pages/`: Astro routes (home, widgets, templates, search, OG image routes)
- `src/components/`: Astro/React UI components (header, sidebar, preview tabs, iframe)
- `src/content/widgets/`: widget metadata/content
- `src/content/templates/`: template metadata/content
- `src/styles/global.css`: global theme and component styles
- `flutter_apps/core/lib/`: Flutter widget/template screens and route map
- `public/flutter_apps/core/`: built Flutter web output (generated)
- `scripts/build.js`: builds all Flutter apps and copies artifacts to `public/flutter_apps/`

## Contributing Workflow

### Add a new widget

1. Create Dart file(s) in `flutter_apps/core/lib/<category>/...`.
2. Register route in `flutter_apps/core/lib/main.dart`.
3. Create markdown entry in `src/content/widgets/<category>/<widget>.md`.
4. If new category, add `src/content/widgets/<category>/index.md`.

### Add a new template

1. Create `src/content/templates/<template>.md`.
2. Add image assets in `src/assets/template_images/` when needed.
3. Fill template frontmatter (`title`, `description`, `heroImage`, links, tags, etc.).

### Before opening a PR

- Ensure Markdown entries and Dart files match.
- Verify each `code_files` path exists.
- Run `pnpm format`.
- Run `pnpm build`.
- If Flutter screens changed, run `pnpm build-apps` and include generated updates when appropriate.

## License

MIT
