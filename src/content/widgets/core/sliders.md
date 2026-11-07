---
title: Sliders
description: A Flutter slider showcase with a value slider, a range slider, and a stepped slider.
app: core
path: /core/sliders
code_files: ["core/sliders.dart"]
---

## How it works

Three values live in state: `_value`, `_range` as `RangeValues`, and `_stepped`, each updated from `onChanged`. `_card` pairs a title and live readout with whichever slider it's handed. All three set `divisions`, which is what makes the `label` bubble appear, so 'Value' and 'Stepped' differ mainly in 100 steps versus 5. Nothing outside the screen reads them.

## Adapting it

- Add `min` where zero isn't valid. `_stepped` can reach Level 0 today.
- Use `onChangeEnd` for saving or API calls, because `onChanged` fires continuously during a drag.
- Promote `_card` to a public widget if you want the same layout in a settings page.
