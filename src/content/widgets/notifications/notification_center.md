---
title: Notification Center
description: A showcase of Flutter's notification center functionality
app: core
path: /notifications/notification_center
code_files: ["notifications/notification_center.dart"]
---

## How it works

`_notifications` is a const list where each entry has a `read` flag, copied into the `_read` set. Unread entries get a tinted `Card` and blue icon; read entries use grey. Those grey values are hardcoded, including a light `Colors.grey[300]` that sits oddly on dark surfaces. `Mark all read` fills `_read` and then disables itself, and tapping a row marks it read and shows a demo `SnackBar`.

## Adapting it

- Load `_notifications` from your endpoint.
- Send `Mark all read` to your API as a batch call alongside the local update.
- Swap the `Colors.grey` shades for `colorScheme` roles, and compute `time` from a timestamp.
