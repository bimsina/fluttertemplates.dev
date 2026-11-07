---
title: Social Profile
description: Cover photo, avatar, bio, follower counts, TabBar grid/list
app: core
path: /social/social_profile
code_files: ["social/social_profile.dart"]
---

## How it works

`NestedScrollView` puts a collapsing header above a `DefaultTabController`. The avatar sits inside the `FlexibleSpaceBar` background: a `Stack` stops the gradient `_avatarRadius` short of the bottom, so the avatar straddles the cover's edge with no transform, no leftover gap and nothing painted over it. It fades out with the header on scroll. The page is a `StatelessWidget`, and tab contents are placeholders.

## Adapting it

- Swap the gradient for a cover image inside the same `Positioned.fill`.
- Convert to a `StatefulWidget` when you add follow state.
- Replace `_StatCell` values and the `itemCount: 9` grid with real data.
