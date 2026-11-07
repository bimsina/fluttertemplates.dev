---
title: Empty - No Connection
description: WiFi-off icon, simulated retry button with loading state
app: core
path: /states/empty_no_connection
code_files: ["states/empty_no_connection.dart"]
---

## How it works

`_loading` swaps the button icon for a small spinner and disables it during a retry. The retry is simulated, and a line under the button says so: `_retry` waits two seconds with `Future.delayed` and resets the state, so no network check happens and the page never leaves this screen. The `mounted` guard does correctly prevent `setState` after disposal.

## Adapting it

- Replace `Future.delayed` in `_retry` with your actual request or a `connectivity_plus` check, then remove the demo line.
- Pass an `onRetry` future into `EmptyNoConnection`, so any screen can reuse it.
- Navigate away from `EmptyNoConnection`, or swap the content, once the call succeeds.
