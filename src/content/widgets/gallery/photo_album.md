---
title: Photo Album
description: A showcase of Flutter's photo album functionality
app: core
path: /gallery/photo_album
code_files: ["gallery/photo_album.dart"]
---

## How it works

`_albums` holds three name and count pairs, listed as `ListTile`s with a tinted `photo_library` icon in each `leading` slot. The subtitle always appends "photos", so an album with one item would read "1 photos". `onTap` shows a demo `SnackBar`, so albums don't open yet.

## Adapting it

- Use `onTap` to push a photo grid for the tapped album.
- Show a cover thumbnail in `leading` in place of the tinted `Container`.
- Load `_albums` from your API, or from the device through a package like `photo_manager`.
