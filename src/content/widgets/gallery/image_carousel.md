---
title: Image Carousel
description: A showcase of Flutter's image carousel functionality
app: core
path: /gallery/image_carousel
code_files: ["gallery/image_carousel.dart"]
---

## How it works

`PageView.builder` shows five tinted placeholders, and `onPageChanged` stores `_currentPage` so the active dot widens from 8px to 24px. Dots are plain `Container`s, so the width snaps rather than animates. The count of 5 is repeated in `itemCount` and `List.generate`, and `dispose` releases `_pageController`.

## Adapting it

- Use a list of image URLs and drive both `itemCount` and `List.generate` from its length.
- Swap the dot `Container` for `AnimatedContainer` to smooth the transition.
