---
title: Feature Comparison
description: A showcase of Flutter's feature comparison functionality
app: core
path: /pricing/feature_comparison
code_files: ["pricing/feature_comparison.dart"]
---

## How it works

A `DataTable` built from the const `_features` list, inside a horizontal `SingleChildScrollView` so narrow screens can pan sideways. All cells are strings, including the dash and check mark for API access. There's no vertical scrolling, so a much longer table would be cut off. Neither the column headers nor the rows have any interaction, and no plan can be chosen here.

## Adapting it

- Update `_features` with your plan limits, or generate it from pricing config shared with your paywall.
- Wrap the scroll view in a vertical `SingleChildScrollView` once rows grow.
- Show `Icon`s in `DataCell` where `'✓'` is used now.
