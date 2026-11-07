---
title: Currency Converter
description: A showcase of Flutter's currency converter functionality
app: core
path: /finance/currency_converter
code_files: ["finance/currency_converter.dart"]
---

## How it works

`_convert` parses `_amountController`, multiplies by the `rate` for `_code` and shows the result under the button, or an error if the amount is invalid. Changing either input clears that result so it can't go stale. The `_rates` are hardcoded sample figures, listed under a "Sample Rates (USD)" heading with each rate in the row's subtitle.

## Adapting it

- Fetch `_rates` from an exchange-rate API and show when they were last updated.
- The base currency is fixed by `prefixText: 'USD '`; add a second dropdown to let users change it.
- `toStringAsFixed(2)` suits this display, but JPY normally has no decimals, so use per-currency formatting.
