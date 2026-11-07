---
title: Tag Input
description: A Flutter tag input with inline chips, comma and paste handling, two-step backspace deletion, suggestions and a tag limit.
app: core
path: /forms/tag_input
code_files: ["forms/tag_input.dart"]
---

An `InputDecorator` wraps a `Wrap` of chips and a borderless `TextField`, so tags and typing share one field outline. `_commit` normalizes input to lowercase with hyphens, then rejects duplicates and anything past `_maxTags` with an inline error. `_onChanged` splits on commas, which also handles pasted lists. Backspace is handled by `_onKey` on the focus node: the first press on an empty field highlights the last chip and the second removes it, and key repeats are ignored so holding the key cannot wipe everything. Change `_suggestions` to query your own source, and adjust the normalizing line in `_commit` if tags should keep spaces or case.
