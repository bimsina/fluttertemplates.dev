---
title: Chart Gallery
description: A showcase of Flutter's chart gallery functionality
app: core
path: /dashboard/chart_gallery
code_files: ["dashboard/chart_gallery.dart"]
---

## How it works

No chart package is involved; all three charts are hand-built. The bar chart is a `Row` of `Container`s with a height of `80 * _barData[i]`, while `_LineChartPainter` and `_DonutChartPainter` draw through `CustomPaint`. The line chart reuses `_barData`, and there are no axes, tooltips or animations.

## Adapting it

- Feed `_barData` and `_labels` from your own series, normalized first, because values are expected between 0 and 1.
- Both painters compare old and new data with `listEquals` in `shouldRepaint`, so live values redraw from a stateful parent.
- `_LineChartPainter` hardcodes `Colors.blue`; pass a color in so it follows the theme like the bars do. The donut's `segments` should sum to 1.
