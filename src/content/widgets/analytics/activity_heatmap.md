---
title: Activity Heatmap
description: A Flutter day-by-hour heatmap in CustomPaint with five color bins, a metric switch and a detail card for the selected time slot.
app: core
path: /analytics/activity_heatmap
code_files: ["analytics/activity_heatmap.dart"]
---

The grid uses seven rows of two-hour buckets, which keeps cells large enough to tap on a phone. `_HeatmapPainter.cellAt` is a static method, so gestures and painting share the same geometry, and `heightFor` grows rows with the available width. Values are rounded into five bins and `_binColor` blends from the empty track to the primary color, so the legend and cells always match. With nothing selected, the ring and card fall back to the busiest slot. Replace `_generate` with your aggregated counts as a list of seven lists, and change `_buckets` and `_slot` together if you want finer time resolution.
