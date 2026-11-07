---
title: Rating Input
description: A Flutter star rating input with half-star precision, hover preview, drag and keyboard control, aspect ratings and a review summary.
app: core
path: /forms/rating_input
code_files: ["forms/rating_input.dart"]
---

`_StarRating` is a standalone control: `_snap` converts pointer position to the next half star, hovering previews without committing, and tapping the current value clears it. Arrow keys adjust by half a star through a `Focus` handler, and `Semantics` exposes it as a slider so screen readers can step it too. Partial stars are one filled icon clipped by `_FractionClipper` over a track icon, so quarter steps would only need a change to `_snap`. The overall rating is required, while aspects and the comment are optional. Edit `_aspects` for your categories and `_labels` for the wording, and send the values in the submit handler.
