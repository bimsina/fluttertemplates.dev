---
title: Team Members
description: A Flutter SaaS team members screen with seat usage, roles, and invite actions.
app: core
path: /saas/team_members
code_files: ["saas/team_members.dart"]
---

## How it works

A seat summary card sits above `ListView.separated` over `_members`. Pending invites reuse the same class awkwardly: `_Member` stores the invitee's address in `name` and `'Invitation sent'` in `email`, with `pending` swapping the avatar for an hourglass. The `9 of 10 seats used` text is a literal, unrelated to the five rows shown, and all actions show a demo `SnackBar`.

## Adapting it

- Split invites into their own model rather than overloading `name` and `email`.
- Compute the `9 of 10 seats used` text from your billing data.
- Open a role and removal menu from the `Icons.more_vert` button, and an invite dialog from `Invite`.
