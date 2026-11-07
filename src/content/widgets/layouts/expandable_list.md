---
title: Expandable List
description: ExpansionTile sections with child items
app: core
path: /layouts/expandable_list
code_files: ["layouts/expandable_list.dart"]
---

## How it works

`ListView.builder` turns each entry of the const `_sections` list into an `ExpansionTile` whose children are `ListTile`s with a small dot icon. Expansion is handled entirely by `ExpansionTile`, so the page needs no state of its own. Item `onTap` handlers show a demo `SnackBar`.

## Adapting it

- Define a section class to replace the map, which removes the `section['items'] as List<String>` cast.
- Add a route or callback per item and call it from `onTap`.
- Set `initiallyExpanded` on the `ExpansionTile` if one section should open by default.
