---
title: Recipe Card
description: A showcase of Flutter's recipe card functionality
app: core
path: /food/recipe_card
code_files: ["food/recipe_card.dart"]
---

## How it works

One scrolling page: a 220px orange `Container` as the hero, a title, a time and servings row, then ingredients and instructions. Ingredients are a list literal mapped to dense `ListTile`s, and the instructions are a single multi-line `Text` with numbers typed by hand. With no parameters or state, there is no way to scale servings or tick anything off.

## Adapting it

- Add a recipe model parameter to `RecipeCard` and replace the inline strings, including `Classic Margherita Pizza`.
- Store steps as a list and generate the numbering, rather than embedding `\n` in one string.
- Swap `Icons.circle` tiles for `CheckboxListTile`s, kept in state, if cooks should tick off ingredients.
