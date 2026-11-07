---
title: API Keys
description: A Flutter API keys screen with reveal, copy, create and revoke actions.
app: core
path: /saas/api_keys
code_files: ["saas/api_keys.dart"]
---

## How it works

Each `_Key` carries a mutable `revealed` flag toggled by the eye icon, plus a sample `secret`, so `value` gives the full key and `masked` the bulleted form. The copy button always copies `value`, even while hidden. `Create key` opens `_CreateKeyDialog`, which rejects blank and duplicate names, then `_generateKey` adds a revealed demo key. `Revoke` confirms before removing the entry. Both are in-memory, and `onCreate` and `onRevoke` report the key's name afterwards.

## Adapting it

- Keep only `prefix` client-side; fetch the secret once at creation, since real keys shouldn't be re-readable.
- Replace `_generateKey` with your API, which should create the secret and show it once.
- Call your API from `onRevoke`, or before `_keys.remove` if failures must keep the entry.
