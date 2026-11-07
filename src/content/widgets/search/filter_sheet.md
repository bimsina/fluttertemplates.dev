---
title: Filter Sheet
description: A Flutter search filter bottom sheet with price range, type and rating chips, a live result count and removable applied filters.
app: core
path: /search/filter_sheet
code_files: ["search/filter_sheet.dart"]
---

`_Filters` is immutable, so the sheet edits a private draft and only returns it from the Show button; dismissing the sheet discards every change. The same `apply` method powers the results list and the live count on the button, which keeps the two from disagreeing. `activeCount` drives the badge and leaves sorting out because it never narrows results. Applied filters appear as removable chips above the list. To filter on a server, keep the class and turn `apply` into a query builder, debouncing the count request. New filters need a field, a line in `copyWith`, a check in `apply` and a section in `_FilterSheet`.
