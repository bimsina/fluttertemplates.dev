---
title: Delivery Tracking
description: A showcase of Flutter's delivery tracking functionality
app: core
path: /food/delivery_tracking
code_files: ["food/delivery_tracking.dart"]
---

## How it works

A vertical status timeline is generated from `_steps`: each `IntrinsicHeight` row has a dot and connector on the left, then the title and optional time. `done` turns a dot green and `isLast` drops the final connector. Color is decided per step, so the line leaving "Out for delivery" is already green before delivery happens. There is no map, polling or ETA.

## Adapting it

- Replace `_steps` with order status from a stream or polling call, rebuilt through a `StreamBuilder`.
- Color each connector from the next step's `done` value if it should only show completed segments.
- Pass the order in as a parameter, replacing `Order #1234` and `Pizza Palace → Your address`.
