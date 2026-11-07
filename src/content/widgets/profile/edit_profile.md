---
title: Edit Profile
description: Form for editing name, bio, location, website, and social links
app: core
path: /profile/edit_profile
code_files: ["profile/edit_profile.dart"]
---

## How it works

`_formKey` wraps four `TextFormField`s via `_buildTextField`, plus a gender dropdown and date picker. `Save` runs `_save`, which calls `validate()`, so an empty name shows its error and stops there; otherwise a `SnackBar` confirms, and nothing is sent anywhere. `_buildSocialLink` fields have controllers, so typed links stay readable on save. All seven controllers are disposed. The camera badge has no tap handler.

## Adapting it

- Send the controller values to your API in `_save`.
- Add URL validators to the website and social fields.
- Attach `image_picker` to the avatar `Stack`.
