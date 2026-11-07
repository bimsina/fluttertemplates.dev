---
title: Search Suggestions
description: Autocomplete, recent searches, trending
app: core
path: /search/search_suggestions
code_files: ["search/search_suggestions.dart"]
---

## How it works

A listener on `_controller` filters `_recent` into `_suggestions` on each keystroke, adding a `Suggestions` block above the `Recent` and `Trending` lists. Only `_recent` is searched, so trending terms never match. The query is lowercased but entries aren't, so a capitalized recent term would be missed. Tapping a recent item fills the field; suggestion and trending taps show a demo `SnackBar`.

## Adapting it

- Replace the `.where` filter with a debounced autocomplete API call.
- Lowercase both sides of `s.contains(q)`.
- Persist `_recent` and submit the query from each `onTap`.
