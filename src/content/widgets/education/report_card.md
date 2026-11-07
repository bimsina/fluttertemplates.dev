---
title: Report Card
description: A showcase of Flutter's report card functionality
app: core
path: /education/report_card
code_files: ["education/report_card.dart"]
---

## How it works

A summary `Card` shows `GPA: 3.8` and the term, followed by one `ListTile` per entry in `_grades` with its letter and percentage. Both summary values are literals, so the GPA is not calculated from the grades listed beneath it. Nothing on the page is interactive.

## Adapting it

- Calculate the GPA from `_grades` using your institution's point scale.
- Add constructor parameters to `ReportCard` for the student and term, replacing `Spring 2025`.
- Decide whether `grade` comes from the server or is derived from `score`, so the two can never disagree.
