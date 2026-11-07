---
title: Edit Record
description: A Flutter admin edit form with grouped fields, switches, and save and cancel actions.
app: core
path: /admin/edit_form
code_files: ["admin/edit_form.dart"]
---

## How it works

The name and email `TextFormField`s use `TextEditingController`s seeded with sample values, while the role dropdown and two `SwitchListTile`s keep state in `_role`, `_active` and `_twoFactor`. Both save buttons call `_save`, which reads the current values into a `SnackBar`. Nothing is validated or stored. Cancel shows a demo `SnackBar`, and the avatar's edit badge is decoration with no tap target.

## Adapting it

- Wrap the `ListView` in a `Form` with a `GlobalKey<FormState>`, then validate the email in `_save`.
- Replace the `SnackBar` in `_save` with your update request.
- Pass the user through the `EditForm` constructor to replace 'Alex Kim' and the default `_role`.
