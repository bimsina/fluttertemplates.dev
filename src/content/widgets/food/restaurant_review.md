---
title: Restaurant Review
description: A showcase of Flutter's restaurant review functionality
app: core
path: /food/restaurant_review
code_files: ["food/restaurant_review.dart"]
---

## How it works

A summary header sits above a `ListView.builder` of `_reviews`. The header is fixed: `4.5`, `128` and the star row are literals, and `List.generate` always draws four full stars plus a `star_half`. Each review card shows an initial in a `CircleAvatar` and as many stars as its `rating`, with no outlines for the rest. Write Review shows a demo `SnackBar`.

## Adapting it

- Use aggregates from your API for the header, and pick `Icons.star_half` from the actual average.
- Open a rating form from the `Write Review` button, then refresh `_reviews`.
- `(r['user'] as String)[0]` throws on an empty name, so guard it for anonymous reviewers.
