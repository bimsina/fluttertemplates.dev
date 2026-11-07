---
title: Trip Itinerary
description: A showcase of Flutter's trip itinerary functionality
app: core
path: /travel/trip_itinerary
code_files: ["travel/trip_itinerary.dart"]
---

## How it works

A summary `Card` tops a timeline made from `List.generate` over `_days`. The connector is a fixed `height: 60` `Container`, so it won't match cards with longer text, and gaps will appear. Trip title and dates are literals: the header's four dates line up with the four `_days` entries, but only by hand, and nothing is interactive.

## Adapting it

- Wrap each row in `IntrinsicHeight` and put the line in `Expanded` so it tracks card height.
- Load `_days` from your trip model, deriving labels from actual dates.
- Replace `Colors.grey[300]` with `outlineVariant` for dark mode.
