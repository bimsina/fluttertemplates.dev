---
title: Simple Profile Page
description: A Flutter profile page with an avatar, stats, and follow and message buttons.
app: core
path: /must_haves/profile_page/profile_page_1
code_files: ["must_haves/profile_page/profile_page_1.dart"]
---

## How it works

A `LayoutBuilder` gives `_TopPortion` two fifths of the height, at least 200px, and everything scrolls in a `SingleChildScrollView`. `_TopPortion` stacks a gradient header with an avatar straddling its lower edge, plus a green status dot. The avatar is a local `Icons.person` placeholder, so the demo needs no network. `_ProfileInfoRow` lays out `ProfileInfoItem` stats, `Follow` toggles `_following`, and `Message` shows a demo `SnackBar`.

## Adapting it

- Pass a user model into `ProfilePage1` and hand its counts to `_ProfileInfoRow`.
- Set the `CircleAvatar`'s `backgroundImage` to your avatar, keeping the icon as a fallback.
- Send `_following` to your API, and open your chat flow from the `message` button.
