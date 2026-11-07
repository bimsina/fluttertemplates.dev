---
title: Email Inbox
description: A showcase of Flutter's email inbox functionality
app: core
path: /notifications/email_inbox
code_files: ["notifications/email_inbox.dart"]
---

## How it works

A `ListView.builder` over the const `_emails` maps. `unread` controls only the subject's font weight, and avatars take the sender's first letter. The subtitle merges sender and preview on a single ellipsized line. There's no mail logic: search, compose and row taps show a demo `SnackBar`, though a tap also adds the row to `_opened`, which clears its bold subject.

## Adapting it

- Define an email model, and load it from your API rather than `_emails`.
- Open the message from `onTap`, and save read status to your backend.
- Add swipe actions by wrapping `ListTile` in `Dismissible`, and connect the `FloatingActionButton` to compose.
