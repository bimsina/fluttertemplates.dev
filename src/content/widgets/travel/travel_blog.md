---
title: Travel Blog
description: A showcase of Flutter's travel blog functionality
app: core
path: /travel/travel_blog
code_files: ["travel/travel_blog.dart"]
---

## How it works

Cards with a 180px header, tinted from `Colors.primaries` with a modulo, plus a title and meta row, built with `ListView.builder` over `_posts`. The author avatar is a blank grey `CircleAvatar`. The heart is a plain `Icon` next to the like count, not a button, and the `Card` has no tap handling, so posts can't be opened. Search only shows a demo `SnackBar`.

## Adapting it

- Fetch `_posts` from your CMS, and add image and slug fields.
- Wrap each `Card` in `InkWell` to open the article.
- Change `Icons.favorite_border` to an `IconButton`, tracking likes per post.
