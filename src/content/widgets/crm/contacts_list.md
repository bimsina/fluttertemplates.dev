---
title: Contacts List
description: A Flutter CRM contacts list with search, avatars, and alphabetical sections.
app: core
path: /crm/contacts_list
code_files: ["crm/contacts_list.dart"]
---

## How it works

`build` groups the const `_contacts` list into a map keyed by `c.name[0]`, sorts the keys into `letters`, and emits a header plus `ListTile`s per letter. Grouping reruns on each rebuild, and an empty name would throw. Keys are case-sensitive, so a lowercase name would get its own section. Search isn't wired up, and add and the call `IconButton` show a demo `SnackBar`.

## Adapting it

- Group once when data arrives, outside `build`, and uppercase the key.
- Add a phone field to `_Contact` and launch `tel:` from the `Icons.call_outlined` button with url_launcher.
- The outer `ListView` builds every row eagerly, so switch to `ListView.builder` or slivers for large address books.
