---
title: Budget Tracker
description: A showcase of Flutter's budget tracking functionality
app: core
path: /finance/budget_tracker
code_files: ["finance/budget_tracker.dart"]
---

## How it works

For each entry in `_categories`, `pct` is `spent / limit`; past 1 the text and bar turn red and the bar value is capped, as the over-limit Shopping row shows, and a `Wrap` stacks the row's labels when text is large. The header uses the same data: `totalSpent` and `totalLimit` are summed in `build`, formatted by `_usd`, and drive the top progress bar, giving $1,025 of $1,250.

## Adapting it

- The `pct > 1` check only fires after overspending; add an amber state at around 0.8 if users need early warning.
- Load `_categories` from your API, and use cents if `int` whole dollars are too coarse.
