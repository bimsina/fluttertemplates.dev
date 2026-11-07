---
title: Button Components
description: A showcase of Flutter's built-in button components and their variants
app: core
path: /core/buttons
code_files: ["core/button_demo.dart"]
---

## How it works

`ButtonDemo` is a reference sheet, not a component. `Wrap` rows show `ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextButton` and `IconButton` variants, the first four in default, icon, loading and disabled forms. The loading versions pair a `CircularProgressIndicator` child with a null `onPressed`, so they ignore taps. The default and icon variants call `_showDemo`, so a tap confirms with a `SnackBar`.

## Adapting it

- For a real loading button, hold a bool, set `onPressed` to null while it's true, and render the 20 px `SizedBox` spinner.
- Style `FilledButton` and friends once in `ThemeData` through `filledButtonTheme` and its siblings, because nothing here shares a style.
- The delete `IconButton.filled` hardcodes `Colors.red`, so use your theme's error colour.
