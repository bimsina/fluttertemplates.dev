---
title: Survey Form
description: Radio, checkboxes, Likert scale, progress bar
app: core
path: /forms/survey/survey_form
code_files: ["forms/survey/survey_form.dart"]
---

## How it works

Three question types map to three fields: `_q1` through `RadioGroup`, `_q2` as a `List<bool>` behind `CheckboxListTile`s, and `_q3` on a 1 to 5 `Slider` with four divisions. Answers do update in state, but the top `LinearProgressIndicator` is stuck at `0.6`. Submit shows an error until `_q1` is answered, then passes all three answers to `onSubmit`, or shows a demo `SnackBar` without it.

## Adapting it

- Compute the `LinearProgressIndicator` value from how many questions are answered.
- Send the answers to your backend from `onSubmit`.
- Move the inline question text and `_q2Options` into a data list so surveys can come from a server.
