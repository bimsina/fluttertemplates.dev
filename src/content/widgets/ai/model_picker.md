---
title: Model Picker
description: A Flutter AI model picker sheet to choose the model and adjust temperature and response length.
app: core
path: /ai/model_picker
code_files: ["ai/model_picker.dart"]
---

## How it works

`_selected`, `_temperature` and `_length` hold the form state, and each `_Model` card highlights by comparing its index to `_selected`. `_SliderTile` is a small wrapper showing a label and display string over a `Slider`, and response length maps onto Short, Medium and Long at the 0.34 and 0.67 cut-offs. Apply only shows a demo `SnackBar`, so selections go nowhere.

## Adapting it

- Persist the three values in the Apply `FilledButton`, or lift them into state your chat screen reads.
- Add an API model id to `_Model`, since `name` is a display label and `_models` is hardcoded.
- Temperature stops at 1 because `_SliderTile` uses the `Slider` default range. Add a `max` parameter if your provider accepts more.
