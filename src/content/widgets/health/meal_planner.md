---
title: Meal Planner
description: A showcase of Flutter's meal planning functionality
app: core
path: /health/meal_planner
code_files: ["health/meal_planner.dart"]
---

## How it works

`_meals` rows render in a `DataTable` inside a `Card`, with the header shaded through `headingRowColor` and `WidgetStateProperty.all`. The table is wider than most phones, so a horizontal `SingleChildScrollView` lets it scroll, while `LayoutBuilder` and a `minWidth` constraint make it fill the card on larger screens. The sample covers Monday to Friday, cells are plain text, and Add Day shows a demo `SnackBar`.

## Adapting it

- Make the screen stateful, and use `onTap` on each `DataCell` to edit a meal.
- Persist `_meals` and append a new row from the `Add Day` button.
