---
title: Expense Breakdown
description: A showcase of Flutter's expense breakdown functionality
app: core
path: /finance/expense_breakdown
code_files: ["finance/expense_breakdown.dart"]
---

## How it works

`total` is folded from `_expenses` at the top of `build`, and both `_DonutPainter` and the legend derive their numbers from it, so amounts only live in one place. The painter draws one stroked arc per category, starting at the top of the ring. A `LayoutBuilder` wraps the body, but its `constraints` are never read.

## Adapting it

- `shouldRepaint` compares `total` and `expenses`, but maps compare by identity, so a list of new maps always repaints.
- Remove `LayoutBuilder`, or use it to place the legend beside the donut on wide screens.
- Guard `total` against zero before dividing if a month can have no spending.
