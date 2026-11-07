---
title: Sparkline Stat Cards
description: A Flutter set of metric cards with CustomPaint sparklines you can scrub to read any week, plus direction-aware change indicators.
app: core
path: /analytics/sparkline_stats
code_files: ["analytics/sparkline_stats.dart"]
---

Each `_StatCard` owns its scrub index, so dragging one trend updates only that card's headline and leaves the others on their latest value. The painter normalizes values to the card's own minimum and maximum, which makes the shape readable but means sparklines are not comparable across cards. `_Metric.lowerIsBetter` flips the delta color, so a falling churn rate shows as good while a falling session length shows as bad. Add a metric by appending to `_metrics` with its weekly values and a formatter. The window toggle only slices the tail of each list, so swap in a query if you load ranges from a server.
