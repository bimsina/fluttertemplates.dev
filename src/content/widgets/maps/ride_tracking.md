---
title: Ride Tracking
description: A Flutter ride tracking screen with a drawn route, an ETA label, and a driver details panel.
app: core
path: /maps/ride_tracking
code_files: ["maps/ride_tracking.dart"]
---

## How it works

A `Stack` puts a full-screen `_RoutePainter` behind a driver panel docked with `Align`. The painter draws two roads, a three-segment route and a plain circle standing in for the car, all as fractions of screen size. Nothing moves: `Arriving in 4 min`, `2.1 mi away` and the driver details are literals, and back calls `Navigator.maybePop` while the others, including `Cancel ride`, show a demo `SnackBar`.

## Adapting it

- Replace `_RoutePainter` with a map SDK and animate a marker from your driver location stream.
- Drive the `Arriving in 4 min` pill from the same stream.
- Confirm in a dialog before cancelling from the `OutlinedButton`.
