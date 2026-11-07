---
title: Donut Chart
description: A Flutter donut chart of storage use with angle-based slice hit testing, a center readout and a legend linked to the selected slice.
app: core
path: /analytics/donut_chart
code_files: ["analytics/donut_chart.dart"]
---

`_sliceAt` converts a pointer position into a slice in two steps: it rejects anything outside the ring by radius, then walks the cumulative sweep from twelve o'clock. Hover and tap both use it, and hover takes priority over the tapped selection through `_active`. `_DonutPainter` draws each slice as a stroked arc and adds surface-colored spokes for the gaps, so the separation stays two pixels at any size. Replace `_slices` to change the data, and keep to five or so segments. The color list alternates dark and light tones, because the tonal roles in a Material scheme sit close together in hue.
