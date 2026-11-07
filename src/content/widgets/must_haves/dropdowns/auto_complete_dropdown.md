---
title: Autocomplete Dropdown
description: A Flutter autocomplete dropdown that filters suggestions as you type.
app: core
path: /must_haves/dropdowns/auto_complete_dropdown
code_files: ["must_haves/dropdowns/auto_complete_dropdown.dart"]
---

## How it works

`AutocompleteTextField` wraps Flutter's `Autocomplete`, which owns the controller, focus node and suggestions overlay, so there's nothing to dispose here. `optionsBuilder` filters `items` by substring on every keystroke, and `fieldViewBuilder` supplies a `TextFormField` so the field joins the `Form`. Validation is selection-only: `onItemSelect` sets `_selectedItem`, `onChanged` clears it when the text diverges, and a typed country fails until it's picked from the list.

## Adapting it

- Replace `_countries` with your own options, or fetch them inside `optionsBuilder`.
- Style the list with `optionsViewBuilder`.
- Use `displayStringForOption` if your options are typed models.
