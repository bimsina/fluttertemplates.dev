---
title: Notification Banners
description: A showcase of Flutter's notification banners functionality
app: core
path: /notifications/notification_banners
code_files: ["notifications/notification_banners.dart"]
---

## How it works

`_banners` holds four `_Banner` entries for info, success, warning and error, differing only in color, icon and text. They render as inline `Card`s, not overlays, and don't animate. Each close `IconButton` removes its banner from `_visible`, and once all are gone a button restores them so the demo can be replayed.

## Adapting it

- Fill `_visible` from your app's real alerts, and drop the restore button.
- Wrap each `Card` in `AnimatedSize` or `Dismissible` for a softer exit.
- Use `Colors.blue[700]` style shades with care: check contrast in dark themes.
