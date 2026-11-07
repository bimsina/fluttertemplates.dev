---
title: Security Settings
description: Security options including 2FA, sessions, login history, and recovery
app: core
path: /profile/security_settings
code_files: ["profile/security_settings.dart"]
---

## How it works

`sessions` and `loginHistory` are lists of maps declared inside `build`, so they're reallocated each rebuild. `_buildSessionTile` hides the logout button on the current device; `_buildLoginHistoryTile` switches icon and color on `isFailed`. Nothing is connected: `Sign Out All Devices`, `Manage` and per-session logouts show a demo `SnackBar`, and the 2FA state is fixed text.

## Adapting it

- Fetch sessions and login events from your auth backend, using typed models instead of `session['device']` lookups.
- Wire the logout `IconButton` to session revocation and refresh the list.
- Wrap the device `Text` in `Flexible`, as a long name will overflow beside the `Current` badge.
