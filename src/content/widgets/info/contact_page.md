---
title: Contact Page
description: A showcase of Flutter's contact page functionality
app: core
path: /info/contact_page
code_files: ["info/contact_page.dart"]
---

## How it works

Four `TextField`s and a `FilledButton` sit in a plain `Column`, with email and phone `ListTile`s underneath. There are no controllers, no validation and no submit logic, so `Send Message` only shows a demo `SnackBar` and typed text is never read. The `Column` also isn't scrollable, which means the layout will overflow once the keyboard opens on a short screen.

## Adapting it

- Wrap the body in a `SingleChildScrollView`, then a `Form`, and convert each `TextField` to a validated `TextFormField`.
- Post the values to your backend from the `FilledButton` callback.
- Use `url_launcher` in the `ListTile` `onTap` handlers for `mailto:` and `tel:` links.
