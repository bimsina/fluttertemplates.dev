---
title: Flash Sale
description: Horizontal scroll with countdown timer, discount badges
app: core
path: /ecommerce/flash_sale
code_files: ["ecommerce/flash_sale.dart"]
---

## How it works

Three deals from `_products` scroll sideways in a `ListView.builder` that's 180px tall at normal text scale and grows with it, with original prices struck through by `TextDecoration.lineThrough`. `Timer.periodic` recomputes `_remaining` from `_endsAt` each second, so late ticks can't drift, and `dispose` cancels it. At zero the timer stops and the header reads "Sale ended". The `-50%` badge is a literal, not calculated from the prices.

## Adapting it

- Set `_endsAt` from your backend, because here the sale restarts each time the screen opens.
- `price` and `original` are strings; store numbers so the badge can be derived.
