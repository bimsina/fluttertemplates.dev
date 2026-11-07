---
title: Energy Usage
description: A Flutter energy usage dashboard with a consumption chart and a per-device breakdown.
app: core
path: /iot/energy_usage
code_files: ["iot/energy_usage.dart"]
---

## How it works

All of it is static data on a `StatelessWidget`. The bar chart is a `Row` of `Container`s, each scaled against `maxVal`, the largest entry in `_week`, with no chart package involved. Friday is highlighted through a hardcoded `i == 4`. The `53.8 kWh` total and cost line are string literals, though the total does match the sum of `_week`.

## Adapting it

- Fetch `_week` and `_breakdown` from your meter API, and compute the headline from the data.
- Replace `i == 4` with today's weekday so the highlight is meaningful.
- Rename `_Usage.kwh`: the code divides it by 100 and prints it as a percent, so it holds a share, not energy.
