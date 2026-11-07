---
title: Simple Articles feed
description: A Flutter articles feed with cover images, titles, and summaries in a scrollable list.
app: core
path: /must_haves/content_feed/news_feed_2
code_files: ["must_haves/content_feed/news_feed_2.dart"]
---

## How it works

`ListView.builder` renders `_articles` as fixed 136px rows, capped at 400px wide by a `BoxConstraints` parent. `maxLines: 2` truncates titles so the height holds. The three small action icons come from mapping a list of `IconData` to `InkWell`s whose `onTap` shows a demo `SnackBar`, and the row itself isn't tappable. `_articles` is sample data, with `postedOn` stored as display text such as `"Yesterday"`.

## Adapting it

- Replace `_articles` with an API call, parsing `Article` from JSON and storing `postedOn` as a `DateTime`.
- Wrap each row in an `InkWell` that opens the article.
- Swap the hardcoded `Color(0xFFE0E0E0)` border for a theme color.
