---
title: Lead Detail
description: A Flutter CRM lead detail with contact info, deal value, and an activity feed.
app: core
path: /crm/lead_detail
code_files: ["crm/lead_detail.dart"]
---

## How it works

All of it is literal: 'Amara Okafor', the $12,400 deal and three activity rows are written directly into `build`, with `_action`, `_stat` and `_activity` as layout helpers. The Call, Email and Meet shortcuts are `InkWell`s that show a `SnackBar` through `_notify`, without placing a call or opening anything. The email and phone `ListTile`s have no `onTap`.

## Adapting it

- Define a lead model and pass it to `LeadDetail` in place of the strings.
- Replace the `_notify` callbacks with url_launcher for `tel:` and `mailto:` links.
- Build `_activity` rows from a list fetched for this lead, and open your edit form from the `Icons.edit` button.
