---
title: AI Response
description: A Flutter AI response view with formatted text, a code block, and a copy button.
app: core
path: /ai/rich_response
code_files: ["ai/rich_response.dart"]
---

## How it works

Nothing is parsed here: the 'Fibonacci in Dart' answer is assembled by hand from `Text` widgets, the `_bullet` helper and `_CodeBlock`. `_CodeBlock` is the reusable part, a dark panel with a language header and a Copy link calling `Clipboard.setData`, though it has no syntax colouring. The thumbs set `_rating`, and tapping one again clears it. Refresh and share show a demo `SnackBar`, and 'Regenerate' is only a label.

## Adapting it

- For real output, replace the hand-written children with a Markdown package and route fenced blocks to `_CodeBlock`.
- Show a `SnackBar` after `Clipboard.setData`, because copying gives no feedback now.
- Send ratings from `_rate`, passing a message id into `RichResponse`.
