---
title: Bar Chart
description: A Flutter bar chart in CustomPaint that switches between stacked and grouped columns, with channel filters and a per-week breakdown card.
app: core
path: /analytics/bar_chart
code_files: ["analytics/bar_chart.dart"]
---

`_BarPainter` reads `_weeks` and paints either stacked or grouped columns depending on `_layout`, capping bars at 24 pixels and rounding only the top ends. Colors are assigned by channel index rather than position, so hiding a channel never repaints the others. The axis step is recalculated from the visible channels, which keeps ticks round as filters change. Selection is simple band math in `_selectAt`, shared by hover, tap and drag. To adapt it, edit `_channels` and `_weeks`, keeping one value per channel in each week, and add a color to the list in `build` for every extra channel.
