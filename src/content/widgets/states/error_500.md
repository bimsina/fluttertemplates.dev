---
title: Error 500
description: Warning icon, expandable error details, retry button
app: core
path: /states/error_500
code_files: ["states/error_500.dart"]
---

## How it works

A `StatelessWidget`, since `ExpansionTile` manages its own open state. The content sits in a `SingleChildScrollView`, so opening the details on a short screen scrolls instead of overflowing. The error text, including the January 2024 timestamp, is a hardcoded string, and `Retry` only shows a demo `SnackBar`.

## Adapting it

- Pass the exception message into `Error500`, and show it only in debug builds.
- Accept an `onRetry` callback for the `FilledButton.icon`.
- Show a support reference in place of raw details in production.
