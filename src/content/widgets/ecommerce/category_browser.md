---
title: Category Browser
description: Grid of category cards with icon and label
app: core
path: /ecommerce/category_browser
code_files: ["ecommerce/category_browser.dart"]
---

## How it works

Six tiles from `_categories` fill a fixed two-column `GridView.builder`, each one an `Icon` above a label. An `InkWell` gives every tile a ripple, and a tap passes the name to `onCategorySelected`, or shows a demo `SnackBar` without it. The column count stays at two on any screen width.

## Adapting it

- Navigate from `onCategorySelected` to your product listing route, using a category id for real data.
- Replace `_categories` with an API response; if categories have artwork, swap the `Icon` for `Image.network`.
- Make `crossAxisCount` depend on width, or use `SliverGridDelegateWithMaxCrossAxisExtent`, so tablets don't get two huge tiles per row.
