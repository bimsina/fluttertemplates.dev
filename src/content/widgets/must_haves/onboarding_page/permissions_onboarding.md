---
title: Permissions Onboarding
description: A Flutter onboarding UI demo for notification, location, camera, and contacts permissions with rationale.
app: core
path: /must_haves/onboarding_page/permissions_onboarding
code_files: ["must_haves/onboarding_page/permissions_onboarding.dart"]
---

## How it works

A UI demo, and the screen says so: the app never asks the OS for anything. `_granted` is a set of indexes that starts empty, and tapping `Allow` calls `_request`, which only adds to the set. Its doc comment shows where to call a permission plugin. `Allowed` is disabled, because apps generally can't revoke a grant. `_perms` pairs each permission with a one-line reason, and `Continue` shows a demo `SnackBar`.

## Adapting it

- Call `permission_handler` in `_request`, updating `_granted` from the returned status.
- Fill `_granted` from current statuses in `initState`.
- Remove the demo line, and link denied permissions to system settings.
