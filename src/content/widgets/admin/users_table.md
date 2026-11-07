---
title: Users Table
description: A Flutter admin users table with search, status badges, row actions, and pagination.
app: core
path: /admin/users_table
code_files: ["admin/users_table.dart"]
previewSize: desktop
---

## How it works

A `DataTable` inside nested vertical and horizontal `SingleChildScrollView`s renders `_visibleUsers`, the const `_users` list filtered by `_query` across name, email, role and status. The footer count comes from those lists. `_statusColor` maps status text to a pill colour, and anything other than Active or Invited gets the error colour. The `PopupMenuButton` has no `onSelected`, and the paging chevrons are disabled because every row fits.

## Adapting it

- Fetch `_users` from your API with page and query parameters. `PaginatedDataTable` can take over paging for large sets.
- Debounce the search `TextField`'s `onChanged` if it refetches.
- Handle `edit` and `remove` in a new `onSelected` on the `PopupMenuButton`.
