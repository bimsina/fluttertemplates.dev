---
title: Message Reactions
description: A Flutter message thread with a long-press reaction picker, toggleable count pills and a sheet showing who reacted.
app: core
path: /chat/message_reactions
code_files: ["chat/message_reactions.dart"]
---

Reactions are stored as a map from `_Reaction` to a set of names, so counts come from set length and toggling is a single remove-or-add in `_toggle`. Empty entries are dropped, which makes pills disappear when the last person removes theirs. The picker opens on long press or right click, double tap sends a quick love, and tapping elsewhere closes it. Long-pressing a pill opens the who-reacted sheet. Reactions use Material icons so they render without an emoji font on web. To use emoji instead, change the enum to hold a string and render `Text` in `_Picker` and `_Pill`, then persist `_toggle` to your backend.
