---
title: Settings Panel
description: A Flutter admin settings panel with tabbed sections for general, security, and billing.
app: core
path: /admin/settings_panel
code_files: ["admin/settings_panel.dart"]
---

## How it works

`DefaultTabController` drives three private tabs: `_GeneralTab`, `_SecurityTab` and `_BillingTab`. The first two are stateful, so their `SwitchListTile`s and the timezone dropdown keep changes, and `AutomaticKeepAliveClientMixin` stops `TabBarView` disposing them, keeping values across tab changes. Nothing is saved, so values reset when the screen closes. `_BillingTab` stays stateless, and the billing card, Visa row and session count are placeholder text.

## Adapting it

- Read initial values from a settings controller, and persist each change in the `onChanged` handlers.
- Do the same for the organization field, which isn't stored anywhere yet.
- Fill `_BillingTab` from your payment provider and send the Manage `TextButton` to its customer portal.
