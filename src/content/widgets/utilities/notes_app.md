---
title: Notes App
description: Notes application with create, edit, and delete functionality
app: core
path: /utilities/notes_app
code_files: ["utilities/notes_app.dart"]
---

## How it works

`_notes` is a mutable list of maps rendered by `_buildNoteCard`, each with a colored top strip. `_openNoteSheet` shows `_NoteSheet`, which owns and disposes its controllers and pops a record on `Save Note`; the page then inserts a new note at the top or updates the one being edited. A blank note is discarded. `PopupMenuButton` handles edit and delete in `onSelected`. Notes live in memory only, and the search and grid buttons show a demo `SnackBar`.

## Adapting it

- Replace the `_notes` maps with a note class persisted to `sqflite` or `hive`, storing a real date.
- Offer undo in a `SnackBar` after delete.
- Connect the search button to a filter over `_notes`.
