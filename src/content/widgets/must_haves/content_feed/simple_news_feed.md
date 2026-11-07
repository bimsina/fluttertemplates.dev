---
title: Simple News Feed
description: A Flutter social-style news feed with text and image posts and action counters.
app: core
path: /must_haves/content_feed/news_feed_1
code_files: ["must_haves/content_feed/news_feed_1.dart"]
---

## How it works

A Twitter-style timeline built from `_feedItems`, where `FeedItem` makes both `content` and `imageUrl` nullable so posts can be text, image or both. `_ActionsRow` scopes icon and button colors with a local `Theme`, and hides counters that are zero. The heart toggles `_favorite` and adjusts the count, other buttons show a demo `SnackBar`, and every post shows the literal `'· 5m'`. The author name uses `Text.rich`, so it inherits the theme's text color in light and dark.

## Adapting it

- Load `_feedItems` from your backend and add a timestamp field to replace `'· 5m'`.
- Add a fallback for failed `NetworkImage`s.
- Rename `User` if it clashes with your auth model, and save likes.
