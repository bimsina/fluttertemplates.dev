---
title: Unit Converter
description: Multi-category unit converter with length, weight, temperature, and more
app: core
path: /utilities/unit_converter
code_files: ["utilities/unit_converter.dart"]
---

## How it works

`_categories` stores each unit's factor to a base unit as a string, and `_getConversionResult` converts by multiplying then dividing. Temperature bypasses that through `_convertTemperature`, going via Celsius; its `toBase` values are unused placeholders. Unparseable input counts as 0. The `Quick Conversions` rows only print two unit names, with no values or tap action, and `_inputController` isn't disposed.

## Adapting it

- Store factors as `double` in a unit class, removing `double.parse`.
- Use `TextInputType.numberWithOptions(signed: true, decimal: true)` so negatives and decimals are reachable.
- Make `_buildQuickConversion` tappable to set `_fromIndex` and `_toIndex`.
