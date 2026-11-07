---
title: File Upload
description: A Flutter file upload dropzone with a dashed CustomPaint border, drag-over state, per-file progress, size checks and retry.
app: core
path: /forms/file_upload
code_files: ["forms/file_upload.dart"]
---

The dropzone is a `DragTarget` for sample chips, which demonstrates the hover and drop states without a platform plugin. Both paths end in `_add`, which applies the size limit and duplicate check before starting `_run`. That method is a timer standing in for an upload stream, and `data.csv` fails once at 60 percent to show the retry path. `_DashedBorderPainter` extracts dashes from the rounded outline using path metrics. For production, call `_add` from your file picker or a desktop drop plugin, write real progress to `_Upload`, and cancel the request in `_remove`. Attach stays disabled until every file finishes.
