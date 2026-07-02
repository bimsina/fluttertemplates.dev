# Flutter Templates

**Production-ready Flutter UI you can preview live and copy.**

[Flutter Templates](https://fluttertemplates.dev/) is an open-source library of real Flutter screens — from single widgets to full apps. Every component runs live in your browser, so you can interact with it, read the source, and copy it straight into your project.

Stop rebuilding the same login form, product grid, or onboarding flow on every app. Find it, try it, ship it.

## What you can do here

- **Browse by category** — 160+ widgets across 27 categories (forms, chat, e-commerce, dashboard, navigation, and more).
- **Preview live** — every widget runs as a real Flutter app in an in-browser preview, not a screenshot.
- **Flip to the source** — switch between the running preview and its Dart code, and copy it.
- **Explore full templates** — complete app examples with live demos, screenshots, and source links.
- **Search** — jump straight to any widget or template by keyword.

## How it works

The repo has two connected parts:

- **Website + content (Astro):** `src/`
- **Flutter source app for previews:** `flutter_apps/core/`

In short:

1. The website renders content from Markdown.
2. Widget pages embed the Flutter web app in an iframe.
3. The iframe receives a `path` query parameter and loads the matching Flutter screen.

## Quick start

### Prerequisites

- Node.js (LTS recommended)
- `pnpm` (this repo uses `pnpm@10`)
- Flutter SDK (required to run or build widget previews)

### Install

```bash
pnpm install
```

### Run locally (full experience)

Run these in two terminals:

```bash
pnpm dev        # Astro site
```

```bash
pnpm run-apps   # Flutter web app on port 8989, for live iframe previews
```

If you run only `pnpm dev`, pages still load, but the widget previews won't work in dev mode.

## Commands

- `pnpm dev` — start the Astro dev server
- `pnpm run-apps` — run the Flutter core app in the browser (`--web-port 8989`)
- `pnpm build` — build the Astro site
- `pnpm build-apps` — build the Flutter web app(s) and copy output to `public/flutter_apps/*`
- `pnpm preview` — preview the built Astro output
- `pnpm deploy` — build and deploy with Wrangler
- `pnpm format` — format `src/` with Prettier

## Content model

Content is powered by Astro collections defined in `src/content.config.ts`.

### Widgets

Location: `src/content/widgets/**`

Common frontmatter fields:

- `title`
- `description`
- `app` (currently `core`)
- `path` (Flutter route used by the iframe, e.g. `/ecommerce/product_grid`)
- `previewSize` (`mobile`, `tablet`, `desktop`)
- `code_files` (paths relative to `flutter_apps/core/lib/`)
- `order`, `icon` (for grouping and navigation)

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

Validation rules for `code_files` are enforced (no absolute paths, `..`, wildcards, or trailing slashes).

### Templates

Location: `src/content/templates/**`

Common frontmatter fields:

- `title`
- `description`
- `type` (`micro-interaction`, `full-app`, `ui-kit`, `single-page`, `clone`)
- `heroImage`, `appImages`
- `githubUrl`, `demoUrl`, `youtubeVideoId`
- `tags`

### How widget previews work

- Widget pages are generated from `src/pages/widgets/[...slug].astro`.
- The page loads source from `flutter_apps/<app>/lib/*` based on `code_files`.
- The preview iframe points to:
  - dev: `http://localhost:8989/?path=<widget-path>&theme=<theme>`
  - production: `/flutter_apps/<app>/index.html?path=<widget-path>&theme=<theme>`
- Flutter route mapping lives in `flutter_apps/core/lib/main.dart` (the `routes` map).

## Project structure

- `src/pages/` — Astro routes (home, widgets, templates, search, OG image routes)
- `src/components/` — Astro/React UI (header, sidebar, preview tabs, iframe, search)
- `src/content/widgets/` — widget metadata and content
- `src/content/templates/` — template metadata and content
- `src/styles/global.css` — theme tokens and global styles
- `flutter_apps/core/lib/` — Flutter widget/template screens and the route map
- `public/flutter_apps/core/` — built Flutter web output (generated)
- `scripts/build.js` — builds all Flutter apps and copies artifacts to `public/flutter_apps/`

## Contributing

### Add a widget

1. Create the Dart screen in `flutter_apps/core/lib/<category>/...`.
2. Register its route in `flutter_apps/core/lib/main.dart`.
3. Add a Markdown entry in `src/content/widgets/<category>/<widget>.md` with matching `path` and `code_files`.
4. For a new category, add `src/content/widgets/<category>/index.md`.

### Add a template

1. Create `src/content/templates/<template>.md`.
2. Add image assets to `src/assets/template_images/` as needed.
3. Fill in the frontmatter (`title`, `description`, `heroImage`, links, tags, etc.).

### Before opening a PR

- Make sure Markdown entries and Dart files match, and every `code_files` path exists.
- Run `pnpm format`.
- Run `pnpm build`.
- If Flutter screens changed, run `pnpm build-apps` and include the generated updates when appropriate.

## License

MIT
