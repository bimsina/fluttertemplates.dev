---
title: Contact Form
description: Name, email, subject, message, and attachment placeholder
app: core
path: /forms/contact/contact_form
code_files: ["forms/contact/contact_form.dart"]
---

## How it works

Four `TextFormField`s sit in a `Form`: all are required, and the email must look like an address. The Message field pairs `maxLines: 5` with `alignLabelWithHint` to keep its label at the top. The attachment row is only an `Icon` and wrapping text marked as a placeholder, and Send validates, then passes a `ContactMessage` to `onSubmit`, or shows a demo `SnackBar` without it.

## Adapting it

- POST to your endpoint from `onSubmit`, with loading and error states.
- Replace the attachment `Row` with a real picker, for example the `file_picker` package.
