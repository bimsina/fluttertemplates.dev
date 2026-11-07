---
title: Flight Booking
description: A showcase of Flutter's flight booking functionality
app: core
path: /travel/flight_booking
code_files: ["travel/flight_booking.dart"]
---

## How it works

`_tripType`, `_passengers` and `_cabin` are the tracked values. `Return` shows only for `Round trip`, with `Depart` filling the row otherwise, but `Multi-city` adds no legs yet. Cities and dates are plain `TextField`s without controllers, so there's no date picker, and `Search Flights` shows a demo `SnackBar`. `_passengers` and `_cabin` hold the dropdown choices, ready for a search request.

## Adapting it

- Add leg rows for `Multi-city`.
- Make the `Depart` and `Return` fields `readOnly`, and call `showDateRangePicker` on tap.
- Add `Form` validation, collecting values into your flight search request.
