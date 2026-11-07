---
title: Restaurant Detail
description: A showcase of Flutter's restaurant detail functionality
app: core
path: /food/restaurant_detail
code_files: ["food/restaurant_detail.dart"]
---

## How it works

With the title inside `FlexibleSpaceBar`, `Pizza Palace` shrinks into the pinned toolbar as the 200px `SliverAppBar` collapses. The gradient and `Icons.restaurant` stand in for a photo. Below sit a rating row, a description and two buttons that show a demo `SnackBar`. Everything is literal, including a lone `$` in the info row that plays the part of a price tier.

## Adapting it

- Give `RestaurantDetail` a model parameter and drop the literals.
- Push your menu route from `View Menu`, and open a maps URL from `Directions` with `url_launcher`.
- The rating line is an unflexed `Row` of `Text`s, so long cuisine names will overflow; switch it to `Wrap`.
