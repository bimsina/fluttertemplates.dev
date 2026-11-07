---
title: Team Page
description: A showcase of Flutter's team page functionality
app: core
path: /info/team_page
code_files: ["info/team_page.dart"]
---

## How it works

`ListView.builder` maps the const `_team` list to `Card`s with a `ListTile`. Avatars are generated: the first letter of the name on a tint from `Colors.primaries`, indexed with a modulo so teams larger than the palette wrap around. Tapping a row shows a demo `SnackBar`.

## Adapting it

- Load the team from your CMS or API instead of the const list.
- Replace `_team` with a typed model that carries a photo URL, and pass it as `backgroundImage` on `CircleAvatar`.
- Use `onTap` to push a bio page, or remove it along with the chevron.
