---
title: Privacy Settings
description: Privacy controls for visibility, online status, read receipts, and blocking
app: core
path: /profile/privacy_settings
code_files: ["profile/privacy_settings.dart"]
---

## How it works

Eight boolean fields back eight switches, each wired by hand through `_buildSwitchTile` with its own `setState` closure. State lives only in this object, so choices vanish when the page is rebuilt from scratch. The lower sections use `_buildSettingTile` with demo `SnackBar` taps and fixed counts, including the destructive `Delete All Chats`, which has no confirmation step yet.

## Adapting it

- Collapse `_profileVisibility`, `_lastSeen` and the rest into one settings object loaded on open.
- Save from `onChanged` optimistically, reverting if the request fails.
- Request location permission before `_locationSharing` turns on, and add a confirmation dialog to `Delete All Chats`.
