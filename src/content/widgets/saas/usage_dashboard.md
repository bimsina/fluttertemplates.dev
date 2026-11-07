---
title: Usage Dashboard
description: A Flutter SaaS usage dashboard with plan limits, metered usage bars, and an upgrade prompt.
app: core
path: /saas/usage_dashboard
code_files: ["saas/usage_dashboard.dart"]
---

## How it works

`_meters` drives one `_MeterTile` each. The tile computes `ratio`, and `near` flips text and bar to `scheme.error` when usage passes 80%, the only real logic here. `_fmt` abbreviates thousands, so 82000 prints as `82k` and 1200 as `1.2k`. Plan name and renewal date are literals, and `Upgrade` shows a demo `SnackBar`.

## Adapting it

- Fetch `_meters` from your billing API, moving the page to a `FutureBuilder` or state object.
- Pull the `0.8` threshold into a named constant, or set it per meter.
- Add a space before `unit` where needed, as `'GB'` currently renders flush against the number.
