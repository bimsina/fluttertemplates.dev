---
title: Stepper
description: A Flutter custom stepper with horizontal and vertical layouts, validation error states and tappable step nodes that block skipped steps.
app: core
path: /core/stepper
code_files: ["core/stepper.dart"]
---

Unlike the Material `Stepper`, this one separates state from layout: `_stateOf` resolves each step to upcoming, current, complete or error, and `_Node` only renders that. Both layouts share `_content` and `_controls`, so the toggle in the app bar changes presentation without losing input. `_goTo` validates every step between the current one and the target, stopping at the first failure, which means tapping ahead cannot skip required fields. Going back is always allowed. Define your steps in `_steps`, add a case to `_isValid` and `_content` for each, and remove the toggle if you only need one layout. Vertical suits long content on phones.
