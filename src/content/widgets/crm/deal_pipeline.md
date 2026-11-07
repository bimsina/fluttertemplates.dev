---
title: Deal Pipeline
description: A Flutter CRM deal pipeline with horizontal stage columns and deal cards.
app: core
path: /crm/deal_pipeline
code_files: ["crm/deal_pipeline.dart"]
previewSize: tablet
---

## How it works

`_stages` nests `_Deal` lists inside `_Stage` objects, and a horizontal `ListView` draws a 240 px column for each, with a vertical `ListView` of `Card`s inside. Despite the kanban look it's read-only: there's no drag support and nothing moves between stages. `value` is a preformatted string like '$12k', so totals can't be computed, and the header only shows `stage.deals.length`.

## Adapting it

- Store `_Deal.value` as a number, format it for display, and add a sum to the stage header.
- Wrap each `Card` in `LongPressDraggable` and each column in `DragTarget`, and move `_stages` into state.
- `owner` holds initials, so replace it with a user id and resolve the `CircleAvatar` from that.
