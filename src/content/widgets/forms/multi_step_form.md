---
title: Multi-Step Form
description: 3-step form with progress and per-step validation
app: core
path: /forms/multi_step/multi_step_form
code_files: ["forms/multi_step/multi_step_form.dart"]
---

## How it works

`_step` selects a page in an `IndexedStack`, and a `LinearProgressIndicator` shows `(_step + 1) / 3`. Each input step has its own `Form`, so Next calls `validate()` only on `_formKeys[_step]` even though `IndexedStack` keeps hidden steps mounted. That same mounting preserves typed values on Back. No field has a controller, `_Step3` shows no summary, and Submit does nothing.

## Adapting it

- Hold field values in `_MultiStepFormState` and pass them into `_Step3` for review.
- Add your submit call to the `FilledButton` for when `_step` reaches 2.
- The Email field accepts any non-empty text, so add a format check to its `validator`.
