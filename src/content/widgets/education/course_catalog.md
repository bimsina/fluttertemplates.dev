---
title: Course Catalog
description: A showcase of Flutter's course catalog functionality
app: core
path: /education/course_catalog
code_files: ["education/course_catalog.dart"]
---

## How it works

Four `_courses` appear in a `GridView.builder` with two columns, or three above 600px, and `childAspectRatio` divides by the text scale so cells grow with large fonts. Each card stacks a tinted `Expanded` block as a thumbnail over the title, instructor and a footer `Wrap` that spreads rating and `hours` apart. Search, filtering and tap handling are all absent, and the data is const maps.

## Adapting it

- Replace the tinted `Container` with course artwork.
- Set `maxLines` and `overflow` on the title `Text`, as long names will eat into the thumbnail.
- Wrap the `Card` in an `InkWell` for navigation to a course page.
