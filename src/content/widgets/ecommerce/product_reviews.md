---
title: Product Reviews
description: Star rating bar chart summary and review cards
app: core
path: /ecommerce/product_reviews
code_files: ["ecommerce/product_reviews.dart"]
---

## How it works

A large average sits beside five `LinearProgressIndicator` bars built from the parallel `_ratings` and `_counts` lists. `_averageRating` weights each rating by its count, giving 4.3 for the sample. Bars scale against `_maxCount`, so the most common rating fills its bar instead of showing a share of all reviews. Review cards below repeat a filled star `rating` times.

## Adapting it

- Merge `_ratings` and `_counts` into one list of objects so they cannot drift out of step.
- Load `_reviews` and `_counts` from your backend; `_maxCount` and `_averageRating` are top-level values computed once, so they must move into the widget.
