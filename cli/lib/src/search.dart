import 'dart:math';

import 'models.dart';

/// Hits scoring below this fraction of the best hit are dropped.
const _relevanceCutoff = 0.15;

class SearchHit {
  const SearchHit(this.widget, this.score);

  final WidgetSummary widget;
  final double score;
}

/// Ranks [widgets] for [query] over title, description, category and the
/// Flutter widgets each one uses.
///
/// Every query word scores per field, and words are weighted by how rare they
/// are in the library: "flutter" appears in nearly every description, so in
/// "flutter login form" it must not outweigh "login". Widgets matching more of
/// the query get a boost over widgets matching only some of it.
List<SearchHit> searchWidgets(Iterable<WidgetSummary> widgets, String query) {
  final terms = query
      .toLowerCase()
      .split(RegExp(r'[\s,/_-]+'))
      .where((term) => term.isNotEmpty)
      .toSet()
      .toList();
  if (terms.isEmpty) return [];

  final docs = [for (final widget in widgets) _Document(widget)];
  final scores = [
    for (final doc in docs) [for (final term in terms) doc.score(term)],
  ];

  final weights = [
    for (var t = 0; t < terms.length; t++)
      () {
        final matches = scores.where((row) => row[t] > 0).length;
        return matches == 0 ? 0.0 : log(1 + docs.length / matches);
      }(),
  ];
  final totalWeight = weights.fold(0.0, (sum, weight) => sum + weight);
  if (totalWeight == 0) return [];

  final phrase = terms.join(' ');
  final hits = <SearchHit>[];
  for (var d = 0; d < docs.length; d++) {
    var score = 0.0;
    var matchedWeight = 0.0;
    for (var t = 0; t < terms.length; t++) {
      if (scores[d][t] == 0) continue;
      score += scores[d][t] * weights[t];
      matchedWeight += weights[t];
    }
    if (score == 0) continue;
    final coverage = matchedWeight / totalWeight;
    score *= coverage;
    if (terms.length > 1 && docs[d].title.contains(phrase)) score *= 2;
    hits.add(SearchHit(docs[d].widget, score));
  }
  hits.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    return byScore != 0 ? byScore : a.widget.title.compareTo(b.widget.title);
  });
  if (hits.isEmpty) return hits;

  // Short words match a lot in passing ("bar" is in every AppBar). Those hits
  // are noise next to real matches, but all there is when nothing else matches.
  final cutoff = hits.first.score * _relevanceCutoff;
  return hits.where((hit) => hit.score >= cutoff).toList();
}

class _Document {
  _Document(this.widget)
    : title = widget.title.toLowerCase(),
      titleWords = _words(widget.title),
      description = widget.description.toLowerCase(),
      descriptionWords = _words(widget.description),
      categories = {
        widget.category.toLowerCase(),
        widget.categoryTitle.toLowerCase(),
      },
      flutterWidgets = [
        for (final name in widget.flutterWidgets) name.toLowerCase(),
      ];

  final WidgetSummary widget;
  final String title;
  final List<String> titleWords;
  final String description;
  final List<String> descriptionWords;
  final Set<String> categories;
  final List<String> flutterWidgets;

  static List<String> _words(String text) =>
      text.toLowerCase().split(RegExp(r'[^\p{L}\p{N}]+', unicode: true));

  int score(String term) {
    // "charts" should find "Chart", and "chart" already finds "charts".
    final stem = term.length > 3 && term.endsWith('s')
        ? term.substring(0, term.length - 1)
        : term;

    var total = 0;
    if (titleWords.contains(term)) {
      total += 10;
    } else if (titleWords.any((word) => word.startsWith(stem))) {
      total += 6;
    } else if (title.contains(stem)) {
      total += 4;
    }

    if (categories.contains(term)) {
      total += 6;
    } else if (categories.any((category) => category.contains(stem))) {
      total += 3;
    }

    if (flutterWidgets.contains(term)) {
      total += 6;
    } else if (flutterWidgets.any((name) => name.contains(stem))) {
      total += 3;
    }

    if (descriptionWords.contains(term)) {
      total += 3;
    } else if (descriptionWords.any((word) => word.startsWith(stem))) {
      total += 2;
    } else if (description.contains(stem)) {
      total += 1;
    }
    return total;
  }
}
