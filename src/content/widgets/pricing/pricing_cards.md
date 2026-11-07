---
title: Pricing Cards
description: A showcase of Flutter's pricing cards functionality
app: core
path: /pricing/pricing_cards
code_files: ["pricing/pricing_cards.dart"]
---

## How it works

`_plans` is a const list of mixed-type maps rendered into `Card`s, with `p['popular'] as bool? ?? false` adding a chip and raised elevation for Pro. Price and period sit on a shared text baseline in a `Row`. Every `Get Started` button shows the same demo `SnackBar`, with nothing identifying the plan. `top: popular ? 0 : 0` is a leftover with no effect.

## Adapting it

- Replace the maps with a plan class, removing `as` casts and the `features` list cast.
- Pass the plan into the `FilledButton` callback and route to checkout.
- Delete the no-op `top` argument, and vary the button label for the free tier.
