---
title: Integrations
description: A Flutter integrations grid to connect and manage third-party services.
app: core
path: /saas/integrations
code_files: ["saas/integrations.dart"]
---

## How it works

`_items` is a const list laid out in rows of up to four tiles. A `LayoutBuilder` picks the column count from the width and text scale, and `IntrinsicHeight` keeps each row's tiles equal. The `connected` flags seed the `_connected` set, which picks an `OutlinedButton` or a `FilledButton`. `Connect` links at once, while `Connected` opens a dialog through `_confirmDisconnect`. Icons are generic Material glyphs tinted with brand colors, not actual logos.

## Adapting it

- Start your OAuth flow in the `Connect` handler, and load statuses from your backend.
- Show a loading state during linking.
- The near-black Notion and GitHub tints in `_items` are hard to see on dark surfaces, so add a theme-aware color.
