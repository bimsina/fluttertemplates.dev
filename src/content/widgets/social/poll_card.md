---
title: Poll Card
description: Poll with animated percentage bars after voting
app: core
path: /social/poll_card
code_files: ["social/poll_card.dart"]
---

## How it works

`_selected` gates the UI: before voting, each option is an empty bar. A tap runs `_vote`, which records the choice and increments `_votes`, so results include your vote. `InkWell` then disables, percentages and a total appear, and each `AnimatedContainer` grows to its share of the `LayoutBuilder` width. The chosen option gets a check icon and a stronger tint. Votes live in local state and reset with the page.

## Adapting it

- Send the vote from `_vote`, and take the updated counts from your API.
- Pass the question and `_options` in as parameters.
- Allow changing a vote by decrementing the previous option first.
