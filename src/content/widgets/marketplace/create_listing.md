---
title: Create Listing
description: A Flutter create-listing form with photo upload, category, price, and description fields.
app: core
path: /marketplace/create_listing
code_files: ["marketplace/create_listing.dart"]
---

## How it works

Only `_category` and `_condition` live in state, each bound to a `DropdownButtonFormField`. The title, price and description `TextField`s have no controllers, so their contents can't be read, and there's no `Form` or validation. The photo row is three decorative tiles with no tap handling. `_label` is a small helper keeping field captions consistent.

## Adapting it

- Add a `Form` with `TextFormField`s and collect the values in the `Post listing` handler.
- Attach `image_picker` to the `Icons.add_a_photo_outlined` tile.
- Use `TextInputType.numberWithOptions(decimal: true)` on the price; plain `TextInputType.number` can hide the decimal key on iOS.
