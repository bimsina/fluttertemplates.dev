---
title: Expandable Sidebar
description: A Flutter expandable side navigation that collapses from labelled items to icon-only.
app: core
path: /navigation/expandable_sidebar
code_files: ["navigation/expandable_sidebar.dart"]
previewSize: tablet
---

## How it works

`AnimatedContainer` tweens the width between 220 and 72 as `_expanded` flips. Each row's label is removed by `if (_expanded)` the moment the toggle fires, and its gap sits inside `Expanded` so a label appearing in a narrow rail can't overflow. Collapsed rows get a `Tooltip` and a `Semantics` label, so icons keep their names, with `MergeSemantics` holding each row to one node. The content pane just prints the selected label.

## Adapting it

- Swap the center `Text` for an `IndexedStack` of real pages keyed by `_selected`.
- Default `_expanded` from screen width with `LayoutBuilder`, because it's currently always open.
