---
title: AI Image Generation
description: A Flutter AI image generation UI with a prompt field, style chips, and a grid of generated results.
app: core
path: /ai/image_generation
code_files: ["ai/image_generation.dart"]
---

## How it works

No image model is involved. `_generate` waits 1200 ms, then `_render` builds four gradient tiles: the selected style picks a base gradient from `_palettes`, and the prompt seeds a hue shift for each tile. Every tile is captioned with its style and prompt. Generate stays disabled while the field is empty or `_generating` is true. Results stay put until you generate again, and the download icons are static.

## Adapting it

- Send `_controller.text` plus `_styles[_style]` from `_generate` to your generation API.
- Keep the returned URLs in state and render them with `Image.network` in place of the `_results` loop.
