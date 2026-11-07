---
title: Admin Dashboard
description: A Flutter admin dashboard layout with a side navigation rail, top bar, metric cards, and a chart.
app: core
path: /admin/dashboard_shell
code_files: ["admin/dashboard_shell.dart"]
previewSize: desktop
---

## How it works

A `NavigationRail` sits beside a content column, and `_index` picks both the heading from `_titles` and the body from `_pages`. Overview has four `_MetricCard`s with literal values and a weekly chart of plain `Container` bars sized as `150 * v`, with no axis or labels. Users, Orders and Settings share `_ListPage`, a simple card list of sample rows.

## Adapting it

- Replace the `_ListPage` entries in `_pages` with your real screens.
- Feed `_MetricCard` from your analytics endpoint. Its `up` flag really means "good", which is why the falling Churn delta shows green.
- Move to a charting package once you need scales or tooltips, which the `BoxDecoration` bars can't provide.
