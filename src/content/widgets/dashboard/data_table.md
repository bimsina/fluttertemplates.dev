---
title: Data Table
description: A showcase of Flutter's data table functionality
app: core
path: /dashboard/data_table
code_files: ["dashboard/data_table.dart"]
---

## How it works

Flutter's built-in `DataTable` renders `_users`, a copy of five hardcoded `_rows`, against an inline `columns` list. Two nested `SingleChildScrollView`s, one horizontal and one vertical, keep wide or long tables reachable. Delete opens a dialog through `_confirmDelete` and removes the row from `_users` only once confirmed. Edit shows a demo `SnackBar`, and there is no sorting, selection or paging.

## Adapting it

- Swap `_rows` for a fetched list of a typed class, which removes the `as String` casts in every `DataCell`.
- Replace `_showDemo` with your edit dialog, and call your API from `_confirmDelete`.
- Move to `PaginatedDataTable` for big datasets, since `DataTable` builds every row up front.
