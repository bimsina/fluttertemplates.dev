---
title: Photo Feed
description: Instagram-style feed with avatar, image, like/comment/share
app: core
path: /social/photo_feed
code_files: ["social/photo_feed.dart"]
---

## How it works

There are no photos yet. Each `Card` in `ListView.builder` has a 250px colored `Container` standing in for an image, tinted from `Colors.primaries` with a modulo so long feeds are safe, between a user header and caption. The heart toggles its post in `_favorites`, while comment and share show a demo `SnackBar`.

## Adapting it

- Replace the `Container` with `Image.network` or `cached_network_image`.
- Send `_favorites` changes to your API, keyed by post ID rather than index.
- Load `_posts` in pages, using a scroll threshold on `ListView.builder`.
