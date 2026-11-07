---
title: About Page
description: A showcase of Flutter's about page functionality
app: core
path: /info/about_page
code_files: ["info/about_page.dart"]
---

## How it works

A stateless page: a `SingleChildScrollView` stacks an icon tile, app name, version line and blurb above two `OutlinedButton`s. Every value is a literal, including `'Version 1.0.0'` and the lorem ipsum paragraph. Both buttons show a demo `SnackBar`, so neither goes anywhere yet.

## Adapting it

- Read the version from `package_info_plus` instead of the hardcoded `Text`, so it tracks your build number.
- Swap `Icons.info_outline` inside the 120px `Container` for your real app icon.
- Point each `OutlinedButton` at your terms and privacy routes or URLs.
