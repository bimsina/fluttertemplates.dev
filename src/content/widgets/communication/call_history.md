---
title: Call History
description: List of incoming, outgoing, and missed calls with quick actions
app: core
path: /communication/call_history
code_files: ["communication/call_history.dart"]
---

## How it works

`calls` is a list of untyped maps rebuilt inside `build`, and `_buildCallTile` translates its `type` and `status` strings into an arrow icon, red styling and a small avatar badge. Those two fields overlap, since every 'missed' call is also 'unanswered'. The trailing `IconButton`s, the search action and the `FloatingActionButton` all lack behaviour.

## Adapting it

- Define a call model with an enum, so `type` and `status` collapse into one field and the `as String` casts disappear.
- Load `calls` from your backend and keep a real timestamp, as `time` is a preformatted string that can't be sorted or grouped.
- Put dialling logic in the `Icons.call` and `Icons.videocam` handlers.
