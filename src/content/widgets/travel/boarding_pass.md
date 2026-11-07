---
title: Boarding Pass
description: A showcase of Flutter's boarding pass functionality
app: core
path: /travel/boarding_pass
code_files: ["travel/boarding_pass.dart"]
---

## How it works

A single `Card` built from literal values, with `_infoRow` handling the label and value pairs. The "barcode" is decoration: `List.generate(20` draws alternating 3px bars that can't be scanned. Those bars are black on a white panel, so they stay readable on a dark card. The `BOARDING` chip is fixed text with no connection to flight status.

## Adapting it

- Replace the bar `Row` with `qr_flutter` or `barcode_widget`, encoding your pass data on the same white panel.
- Pass a booking model into `BoardingPass`.
- Drive the `Chip` label from live status, and add perforation styling if you want a ticket shape.
