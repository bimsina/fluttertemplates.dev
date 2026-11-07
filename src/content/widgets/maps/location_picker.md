---
title: Location Picker
description: A Flutter location picker with a center pin, a mock street grid, and a confirm-address sheet.
app: core
path: /maps/location_picker
code_files: ["maps/location_picker.dart"]
---

## How it works

The classic fixed-pin pattern, with the map faked. `_GridPainter` draws a static street grid; a `Stack` centers `Icons.location_on`, nudged up by 28px of bottom padding so its tip meets the small dot marking the true center. Nothing pans. `Change` opens a `SimpleDialog` of `_sampleLocations`, and `Confirm location` passes the chosen `PickedLocation` to `onLocationSelected`, or shows a demo `SnackBar` without it.

## Adapting it

- Replace the `CustomPaint` with a real map; keep the pin overlay and read the camera target when movement stops.
- Reverse-geocode that target into a `PickedLocation`, replacing `_sampleLocations`.
- Return the result with `Navigator.pop` from `onLocationSelected`.
