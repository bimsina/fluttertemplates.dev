---
title: Food Menu
description: A showcase of Flutter's food menu functionality
app: core
path: /food/food_menu
code_files: ["food/food_menu.dart"]
---

## How it works

`_sections` nests item maps inside named groups, and `ListView.builder` iterates over those groups rather than dishes, spreading each group's items into a `Column`. So a whole section builds at once, which is harmless at this size. Casting `section['items'] as List` leaves `item` dynamic, meaning key typos only fail at runtime. `_order` maps dish names to quantities: add and remove buttons call `_change`, and a footer shows the count and `_total`.

## Adapting it

- Define section and item classes to replace the maps in `_sections`, removing the casts.
- Send `_order` to your cart from `_change`.
- For long menus, flatten headers and dishes into one list so `ListView.builder` stays lazy per row.
