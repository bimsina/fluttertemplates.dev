---
title: FAQ Page
description: A showcase of Flutter's FAQ page functionality
app: core
path: /info/faq_page
code_files: ["info/faq_page.dart"]
---

## How it works

`_faqs` is a const list of question and answer maps, rendered as one `ExpansionTile` per `Card`. The page is a `StatelessWidget`: each tile manages its own open state, so several answers can stay open at the same time. The content is hardcoded in the file, there's no search, and open tiles aren't remembered after leaving the page.

## Adapting it

- Load `_faqs` from your CMS or API, and give it a typed model instead of `faq['q'] as String`.
- For a true accordion, make the page stateful, give each tile an `ExpansibleController` and collapse the others inside `onExpansionChanged`.
- Add a search field that filters `_faqs` for longer lists.
