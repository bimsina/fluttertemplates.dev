---
title: Flashcard
description: A showcase of Flutter's flashcard functionality
app: core
path: /education/flashcard
code_files: ["education/flashcard.dart"]
---

## How it works

`_cards` lives in `_FlashcardState` alongside `_index` and `_showBack`. Tapping the `GestureDetector` toggles `_showBack`, which swaps the text and deepens the blue tint, so the "flip" is an instant change rather than a 3D animation. The chevron buttons disable themselves at either end of the deck, and moving between cards always returns to the front.

## Adapting it

- For a true flip, drive a `Transform` rotation from an `AnimationController`, switching faces at the halfway point based on `_showBack`.
- Accept the deck as a constructor argument instead of the two hardcoded `_cards`.
- Record known and unknown answers against `_index` if you want spaced repetition.
