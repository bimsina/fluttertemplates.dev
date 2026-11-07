---
title: Calculator
description: Functional calculator with basic operations and percentage support
app: core
path: /utilities/calculator
code_files: ["utilities/calculator.dart"]
---

## How it works

A working calculator: `_onButtonPressed` runs a `switch` over labels and hands most keys to small methods like `_pressOperator`, holding `_firstOperand` and `_operator` between presses. Pressing another operator evaluates the pending one, so `2 + 3 + 4 =` gives 9, strictly left to right with no precedence. Dividing by zero or overflowing shows `Error` until `C` or a new number, and a second decimal point is ignored. Results are plain doubles, rounded to 12 significant digits in `_format`.

## Adapting it

- Add operator precedence if `2 + 3 × 4` should give 14.
- Use `Decimal` from the `decimal` package for exact results.
- Add a history list by keeping each `_expression` and result.
