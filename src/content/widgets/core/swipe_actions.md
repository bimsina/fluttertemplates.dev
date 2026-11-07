---
title: Swipe Actions
description: A Flutter list with iOS-style swipe actions on both sides, full-swipe commit, one open row at a time and undoable delete.
app: core
path: /core/swipe_actions
code_files: ["core/swipe_actions.dart"]
---

`_SwipeRow` is built from a gesture detector and an unbounded `AnimationController` holding the pixel offset, which allows resting positions that `Dismissible` does not offer. On release it either commits the outermost action past 60 percent of the width, snaps open, or closes. A shared `ValueNotifier` tracks the open row, so starting a swipe elsewhere closes the previous one. While open, a tap on the row closes it instead of reaching the content. Pass any number of `_SwipeAction` items to `leading` and `trailing`, and adjust `_actionWidth` and `_commitFraction` to tune the feel. The `id` type can be generalized for other row models.
