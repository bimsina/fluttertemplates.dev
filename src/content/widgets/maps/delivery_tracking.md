---
title: Delivery Tracking
description: A Flutter delivery tracking map with the courier path and step-by-step order status.
app: core
path: /maps/delivery_tracking
code_files: ["maps/delivery_tracking.dart"]
---

## How it works

No map SDK here. `_MiniMapPainter` paints a colored rectangle and one cubic route, with the courier icon simply centered over it. The timeline comes from `_steps` and the constant `_currentStep`: each `_StepRow` compares its index to that value to decide done and active styling, and `IntrinsicHeight` lets the connector line stretch to match the text. The class is named `CourierTracking`.

## Adapting it

- Turn `_currentStep` into a value from your order status stream, making the page stateful.
- Replace `_MiniMapPainter` with `google_maps_flutter` or `flutter_map`, and move the marker with courier coordinates.
- Launch the dialer from the call `IconButton`, which shows a demo `SnackBar`.
