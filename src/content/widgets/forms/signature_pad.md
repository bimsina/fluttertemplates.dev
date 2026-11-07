---
title: Signature Pad
description: A Flutter signature pad with speed-sensitive stroke width, smoothed curves, undo, ink colors and export to PNG bytes.
app: core
path: /forms/signature_pad
code_files: ["forms/signature_pad.dart"]
---

Pointer samples are stored per stroke with a width derived from speed in `_extendStroke`, then low-pass filtered so thickness never jumps. `_SignaturePainter` draws quadratic curves through segment midpoints, which smooths sparse input, and repaints from a `ValueNotifier` so drawing does not rebuild the screen. `_save` captures the `RepaintBoundary` as PNG bytes at twice the resolution, and those bytes are what you upload. The export includes the background and guide line, so move them outside the boundary for a transparent signature. The screen deliberately avoids a scroll view, which would compete for vertical drags. Each `_InkSwatch` exposes its name and selected state through `Semantics`. Tune the 0.45 and 1.5 width limits to change the pen.
