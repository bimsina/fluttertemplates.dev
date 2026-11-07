---
title: Product Search
description: Search bar with filter chips (price, category, rating) and results
app: core
path: /ecommerce/product_search
code_files: ["ecommerce/product_search.dart"]
---

## How it works

`_results` narrows the sample `_products` by `_query`, `_priceRange`, `_category` and `_minRating`, and a message replaces the list when nothing matches. Those values come from the `AppBar` `TextField`, two `DropdownButtonFormField`s and a `Slider`. Each `FilterChip` names an active filter and clears it on tap; with no filter set, the chip is disabled.

## Adapting it

- Replace `_results` with a debounced call to your search API once the catalog outgrows memory.
- `_inPriceRange` matches the dropdown's strings, so change both together.
- Swap the tinted `Container` for a product image.
