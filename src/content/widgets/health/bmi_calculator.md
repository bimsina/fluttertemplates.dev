---
title: BMI Calculator
description: A showcase of Flutter's BMI calculator functionality
app: core
path: /health/bmi_calculator
code_files: ["health/bmi_calculator.dart"]
---

## How it works

`_heightController` and `_weightController` start at `170` and `70`. `_calculate` parses both with `double.tryParse`, applies weight over height in meters squared, and picks a category using an `if` plus a Dart 3 relational `switch` such as `case < 25`. The result `Card` appears once `_bmi` is set, and invalid input is silently ignored, leaving any earlier result on screen.

## Adapting it

- Add an `else` to the `h > 0 && w > 0` check to show an error and clear `_bmi`.
- Support imperial units by converting before the formula in `_calculate`, and update the `Height (cm)` labels.
- Fold the first check into the `switch` with `case < 18.5` to drop the `if`.
