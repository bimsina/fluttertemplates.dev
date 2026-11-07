---
title: Roles & Permissions
description: A Flutter roles and permissions matrix with toggleable access per role.
app: core
path: /admin/roles_permissions
code_files: ["admin/roles_permissions.dart"]
previewSize: tablet
---

## How it works

A role-by-permission matrix is drawn from `_roles`, `_perms` and a nested `_grid` of booleans indexed as `_grid[p][r]`. Ticking a `Checkbox` mutates that list in `setState` and nothing is saved, so changes vanish with the screen. The Admin column is locked by passing a null `onChanged` when `r == 0`, which relies on Admin staying first in `_roles`.

## Adapting it

- Build `_grid` from your backend's response. A map keyed by permission id is safer than lists aligned by position.
- Send updates from the `onChanged` callback, or add a save button and batch them.
- Replace the `r == 0` check with a per-role locked flag if roles become user-defined.
