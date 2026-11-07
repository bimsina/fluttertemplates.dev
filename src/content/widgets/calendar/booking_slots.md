---
title: Booking Slots
description: A showcase of Flutter's booking slots functionality
app: core
path: /calendar/booking_slots
code_files: ["calendar/booking_slots.dart"]
---

## How it works

`_selectedSlot` holds the chosen index into the const `_slots` list, with -1 meaning none, and tapping the active `FilterChip` deselects it. Confirm Booking stays disabled until something is picked, then passes the time to `onConfirm`, or shows a demo `SnackBar` without it. The 'March 15, 2025' heading and all ten times are hardcoded, and a slot can't be marked as taken.

## Adapting it

- Fetch `_slots` for a date passed into `BookingSlots`, which also replaces the heading.
- Add an availability flag and pass a null `onSelected` for taken slots, which disables that `FilterChip`.
- Post the booking from `onConfirm`, and handle the conflict when someone else got there first.
