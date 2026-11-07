---
title: Maintenance Page
description: Construction icon, estimated return time
app: core
path: /states/maintenance_page
code_files: ["states/maintenance_page.dart"]
---

## How it works

A static notice with `Icons.construction`, a heading, and a return time written into the sentence as `2:00 PM today`. The stateless page has no timer or status check. Its `OutlinedButton.icon` shows a refresh icon alongside `Check back later`, and tapping it shows a demo `SnackBar`.

## Adapting it

- Read the end time from remote config instead of the `2:00 PM today` literal, so it can change without a release.
- Use the `OutlinedButton.icon` to re-check status, and route back into the app once maintenance ends.
- Give `MaintenancePage` a time parameter, formatted in the user's locale.
