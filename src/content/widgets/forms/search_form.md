---
title: Advanced Search
description: Multiple filters - text, date range, category, checkboxes
app: core
path: /forms/search/search_form
code_files: ["forms/search/search_form.dart"]
---

## How it works

`_category` and `_dateRange` are each updated by a `DropdownButtonFormField`, and `_options` is a `Set` behind the three `FilterChip`s, starting with `Option C`. Search requires a query, then passes it and the filters to `onSearch`, or shows a demo `SnackBar` without it. No results area exists.

## Adapting it

- Run the query from `onSearch`, then show results below or on a new route.
- Rename `Option A` through `Option C` to filters that mean something in your app.
