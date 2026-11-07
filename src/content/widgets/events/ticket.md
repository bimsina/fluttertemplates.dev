---
title: Event Ticket
description: A Flutter event ticket with a QR-style code, seat details, and a perforated pass design.
app: core
path: /events/ticket
code_files: ["events/ticket.dart"]
---

## How it works

The QR code is decorative: `_QrPainter` fills a 21x21 grid from `Random(42)` under three finder squares, so it won't scan, and a "Sample QR, not scannable" label says so. The ticket is two `ClipPath` halves, and `_TicketHalfClipper` cuts a half-circle from each end of their shared edge, so the notches are real holes on any background. Event, seat and code values are all literals.

## Adapting it

- Replace `_QrPainter` with a real encoder such as the `qr_flutter` package, encoding a code from your backend, then remove the label.
- Pass ticket data into `Ticket` and feed it through `_info`.
- `_notchRadius` sets the cut-out size and the inset of the dashed line.
