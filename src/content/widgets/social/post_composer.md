---
title: Post Composer
description: New post with text field, image attachment, character count
app: core
path: /social/post_composer
code_files: ["social/post_composer.dart"]
---

## How it works

`_controller` feeds a live `0/500` style counter, kept current by a `setState` call in `onChanged`. The limit isn't enforced, as the field has no `maxLength`. The image button toggles `_hasImage`, showing a grey placeholder rather than opening a picker, and `Post`, disabled while the draft is blank, clears it and shows a demo `SnackBar`.

## Adapting it

- Set `maxLength: 500` with a hidden counter, or disable `Post` past the limit.
- Replace `_hasImage` with a selected file from `image_picker`.
- Submit to your API from `_post`, clearing the draft only on success.
