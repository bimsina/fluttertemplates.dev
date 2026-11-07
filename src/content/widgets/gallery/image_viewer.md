---
title: Image Viewer
description: A showcase of Flutter's image viewer functionality
app: core
path: /gallery/image_viewer
code_files: ["gallery/image_viewer.dart"]
---

## How it works

A black `Scaffold` and transparent `AppBar` frame an `InteractiveViewer` that zooms from 1x to 5x by pinch or scroll wheel and pans once zoomed. The picture comes from `_PlaceholderPhotoPainter`, so no asset or network image is needed. The share and download `IconButton`s show a demo `SnackBar`, and the class takes no parameters.

## Adapting it

- Replace the `CustomPaint` with an `Image.network`.
- Add a URL and title to the `ImageViewer` constructor.
- Connect `Icons.share` to a package like `share_plus`, and `Icons.download` to your file-saving logic.
