---
title: Quiz Screen
description: A showcase of Flutter's quiz screen functionality
app: core
path: /education/quiz_screen
code_files: ["education/quiz_screen.dart"]
---

## How it works

One hardcoded question renders through `RadioGroup` and `RadioListTile`, with `_selected` starting at `-1`. Submit stays disabled until an option is picked. It passes the index to `onAnswer` and Skip passes null, with a demo `SnackBar` when `onAnswer` is omitted. `_currentQuestion` and `_totalQuestions` are final, so the title and `LinearProgressIndicator` stay on 1 of 5, and no correct answer is stored anywhere.

## Adapting it

- Add a question list holding options and the correct index, and make `_currentQuestion` mutable.
- In `_answer`, score the choice, advance, then reset `_selected` to `-1`.
- Treat null as a skip, and show a results screen after `_totalQuestions`.
