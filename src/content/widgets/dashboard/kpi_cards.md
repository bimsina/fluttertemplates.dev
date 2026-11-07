---
title: KPI Cards
description: A showcase of Flutter's KPI cards functionality
app: core
path: /dashboard/kpi_cards
code_files: ["dashboard/kpi_cards.dart"]
---

## How it works

Each `_Kpi` in `_kpis` becomes a `Card` with a value, a target line and a `LinearProgressIndicator`. `percentVsTarget` is computed from the numeric `value` and `target`, and the arrow follows its sign. `higherIsBetter` sets the color through `isGood`, so Churn falling below target shows green. `progress` is attainment capped at 1, which fills every bar here because all four sample KPIs beat their targets.

## Adapting it

- Load `_kpis` from your API instead of the const list.
- Guard against a `target` of 0, which `percentVsTarget` would divide by.
