---
title: Recent Searches
description: A Flutter recent searches list with de-duplicated history, refine and remove actions, clear all with undo, and live filtering.
app: core
path: /search/recent_searches
code_files: ["search/recent_searches.dart"]
---

`_search` moves a query to the top of `_recent`, compares case-insensitively to avoid duplicates and trims the list to `_limit`. Typing filters the history and adds a direct search row, while editing the text after a search returns from results to history. The arrow button uses `_refine` to copy a past query into the field without running it. Removal and clearing share `_offerUndo`, which restores the exact previous position. History is held in memory, so load and save `_recent` with your storage layer to keep it between sessions. Replace `_Results` and `_catalog` with your own search call.
