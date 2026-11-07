---
title: Prompt Composer
description: A Flutter AI prompt composer with an expanding input, attachment and voice buttons, and a send action.
app: core
path: /ai/prompt_composer
code_files: ["ai/prompt_composer.dart"]
---

## How it works

The one live interaction is the suggestions: each `ActionChip` writes its string from `_suggestions` into `_controller`, and the `TextField` grows from one line to five. Nothing in the toolbar row is connected. The image, attachment, mic and send `IconButton`s show a demo `SnackBar`, and the 'GPT-4o' pill is a static `Row` rather than a menu.

## Adapting it

- Read `_controller.text` in the `IconButton.filled` handler, send it to your model, then clear the field.
- Replace the pill's `Container` with a `PopupMenuButton` and hold the chosen model in state.
- Hook `Icons.attach_file` and `Icons.add_photo_alternate_outlined` to a file picker, and show selected files above the `TextField`.
