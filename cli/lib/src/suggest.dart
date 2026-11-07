import 'dart:math';

/// Returns up to [limit] of [candidates] that look like what [input] meant.
///
/// Ids are matched whole and by their last segment, so a bare `signup_terms`
/// or a wrong folder still finds `auth/signup_terms`.
List<String> closeMatches(
  String input,
  Iterable<String> candidates, {
  int limit = 3,
}) {
  final needle = input.toLowerCase();
  final slug = needle.split('/').last;
  final threshold = max(2, needle.length * 2 ~/ 5);

  final scored = <(String, int)>[];
  for (final candidate in candidates) {
    final lower = candidate.toLowerCase();
    var distance = min(
      levenshtein(needle, lower),
      levenshtein(slug, lower.split('/').last),
    );
    if (slug.length >= 3 && lower.contains(slug)) distance = min(distance, 1);
    if (distance <= threshold) scored.add((candidate, distance));
  }
  scored.sort((a, b) {
    final byDistance = a.$2.compareTo(b.$2);
    return byDistance != 0 ? byDistance : a.$1.compareTo(b.$1);
  });
  return [for (final (candidate, _) in scored.take(limit)) candidate];
}

int levenshtein(String a, String b) {
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final substitution =
          previous[j - 1] +
          (a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1);
      current[j] = min(substitution, min(previous[j], current[j - 1]) + 1);
    }
    previous = current;
  }
  return previous[b.length];
}
