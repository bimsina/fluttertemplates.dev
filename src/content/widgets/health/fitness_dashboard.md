---
title: Fitness Dashboard
description: A showcase of Flutter's fitness dashboard functionality
app: core
path: /health/fitness_dashboard
code_files: ["health/fitness_dashboard.dart"]
---

## How it works

A summary card built from two `_StatChip`s sits above `_stats`, rendered as `ListTile`s. Entries differ in shape: Steps and Calories have a `target`, while Active has a `unit`, so `s['target'] != null` decides on a subtitle. Trailing text joins value and unit with a space, giving 45 min. All figures are hardcoded, and the two quick action buttons show a demo `SnackBar`.

## Adapting it

- Replace `_stats` with data from a package like `health`, which reads HealthKit and Health Connect.
- Make `value` and `target` numeric so each row can show a `LinearProgressIndicator`.
- Wire `Start Workout` and `Log` to your own routes.
