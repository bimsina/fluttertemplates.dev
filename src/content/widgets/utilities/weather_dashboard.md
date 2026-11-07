---
title: Weather Dashboard
description: Weather app with current conditions, hourly forecast, and 7-day outlook
app: core
path: /utilities/weather_dashboard
code_files: ["utilities/weather_dashboard.dart"]
---

## How it works

Sample data with real clock labels. `_hourlyTemps` and `_week` are consts on a `StatelessWidget`; only the date, weekday names and hour labels come from `DateTime.now()`, read at build, so they don't tick. `_hourLabel` formats 12-hour labels counting from the current hour. The `H:` and `L:` header reads today's entry in `_week`, which matches the hourly peak and trough. `_buildDayForecast` draws each bar from that day's low to high within the week's range.

## Adapting it

- Fetch from your weather API and pass in a model to replace `_hourlyTemps` and `_week`.
- Use `DateFormat('ha')` from `intl` in `_hourLabel` for locale-aware labels.
- Connect the menu button, which shows a demo `SnackBar`, to a city switcher.
