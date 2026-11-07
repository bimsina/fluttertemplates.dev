---
title: Search Results
description: Filter/sort row, highlighted matching text
app: core
path: /search/search_results
code_files: ["search/search_results.dart"]
---

## How it works

Search runs locally over the sample `_results`. Typing filters by title, and `_highlight` splits each title into `TextSpan`s so matches show bold in the primary color. The `FilterChip`s narrow results by `type`, one at a time, and the sort `DropdownButton` orders by `daysOld` on `Date`, keeping list order on `Relevance`. All three values live in state, and `_visible` recomputes them in `build`. An empty match shows `No results`.

## Adapting it

- Call your search endpoint from `onChanged` with a debounce, in place of `_results`.
- Pass `_filter` and `_sort` as query parameters.
- Add a loading state around the `ListView.builder`.
