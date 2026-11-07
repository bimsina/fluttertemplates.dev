---
title: Event Schedule
description: A Flutter event schedule with a day selector and a timeline of sessions.
app: core
path: /events/schedule
code_files: ["events/schedule.dart"]
---

## How it works

Each timeline row is wrapped in `IntrinsicHeight`, which lets the connector line inside `Expanded` stretch to match the session card's height. The `keynote` flag on `_Session` fills the dot and switches the card to `primaryContainer`. `_agendas` holds one session list per entry in `_days`, and the chips pick one through `_day`.

## Adapting it

- Keep `_agendas` and `_days` the same length, or build both from one list of day objects.
- Add speaker and description fields to `_Session`, and make the card tappable.
- `IntrinsicHeight` adds an extra layout pass per row; that's fine for a day's agenda, but measure it before showing hundreds of rows.
