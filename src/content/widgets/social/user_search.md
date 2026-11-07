---
title: User Search
description: Search with real-time filtering, Follow buttons
app: core
path: /social/user_search
code_files: ["social/user_search.dart"]
---

## How it works

Filtering happens inside `build`: `_query` is compared case-insensitively against the const `_users`, and an empty query returns everything. Each keystroke's `setState` recomputes `filtered`, which is fine for five names. There's no empty-results message. `Follow` toggles the name in `_following`, which relabels that row, and survives filtering.

## Adapting it

- Swap the local `.where` for a debounced API call as user counts grow.
- Key `_following` by user ID, and save changes to your API.
- Show a message when `filtered` is empty.
