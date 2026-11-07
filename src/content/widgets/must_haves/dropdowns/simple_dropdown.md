---
title: Simple Dropdown
description: A Flutter dropdown menu for selecting a single option from a list.
app: core
path: /must_haves/dropdowns/simple_dropdown
code_files: ["must_haves/dropdowns/simple_drop_down.dart"]
---

## How it works

Three looks, one builder. `_dropDown` wraps `DropdownButton<String>` and exposes optional styling parameters; the outlined and red variants pass an empty `Container` as `underline` and put the decoration on a parent. All three read and write the single `_selectedFruit`, so choosing in one changes the others. That's fine for a demo but wrong for a real form.

## Adapting it

- Give each dropdown its own value, passing the value and callback into `_dropDown`.
- Replace `_fruits` with your options, ideally typed values instead of display strings.
- Delete the `icon` parameter unless you plan to use it, since no caller sets it.
