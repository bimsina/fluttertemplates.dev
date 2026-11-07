import 'package:path/path.dart' as p;

import 'models.dart';

/// The class a user should instantiate after adding a widget.
class PublicWidget {
  const PublicWidget({
    required this.name,
    required this.file,
    required this.isConst,
    required this.needsArguments,
  });

  final String name;

  /// The registry path of the file declaring it.
  final String file;
  final bool isConst;
  final bool needsArguments;

  /// How to create it in code, e.g. `const SignupTerms()`.
  String get expression {
    if (needsArguments) return '$name(/* see its constructor */)';
    return isConst ? 'const $name()' : '$name()';
  }
}

final _classDeclaration = RegExp(
  r'^(abstract\s+)?(?:(?:base|final|sealed)\s+)?class\s+([A-Z]\w*)'
  r'(?:<[^>{]*>)?\s+extends\s+(\w+)',
  multiLine: true,
);
final _anyClass = RegExp(
  r'^(?:abstract\s+|base\s+|final\s+|sealed\s+)*class\s',
  multiLine: true,
);

/// Picks the main public widget of [detail], or null if it declares none.
///
/// Sources are not annotated, so this relies on the library's conventions: the
/// main class is named after the file or the id, and otherwise comes first in
/// its file. For multi-file templates `main.dart` and shallow files come first.
PublicWidget? findPublicWidget(WidgetDetail detail) {
  final files = [...detail.files]..sort(_entryPointsFirst);
  final found = <PublicWidget>[
    for (final file in files) ..._publicWidgets(file),
  ];
  if (found.isEmpty) return null;

  final slug = _normalize(detail.id.split('/').last);
  for (final widget in found) {
    if (_normalize(widget.name) == slug) return widget;
  }
  // In a template most files are named after their class, so this only says
  // something when there is a single file.
  if (detail.files.length == 1) {
    final stem = _normalize(
      p.posix.basenameWithoutExtension(files.single.path),
    );
    for (final widget in found) {
      if (_normalize(widget.name) == stem) return widget;
    }
  }
  return found.first;
}

int _entryPointsFirst(WidgetFile a, WidgetFile b) {
  int rank(WidgetFile file) =>
      p.posix.basename(file.path) == 'main.dart' ? 0 : 1;
  final byRank = rank(a).compareTo(rank(b));
  if (byRank != 0) return byRank;
  return a.path.split('/').length.compareTo(b.path.split('/').length);
}

String _normalize(String name) => name.replaceAll('_', '').toLowerCase();

Iterable<PublicWidget> _publicWidgets(WidgetFile file) sync* {
  for (final match in _classDeclaration.allMatches(file.content)) {
    final isAbstract = match[1] != null;
    if (isAbstract || !match[3]!.endsWith('Widget')) continue;
    yield _describe(match[2]!, file, match.end);
  }
}

PublicWidget _describe(String name, WidgetFile file, int bodyStart) {
  final source = file.content;
  final next = _anyClass.allMatches(source, bodyStart);
  final body = source.substring(
    bodyStart,
    next.isEmpty ? source.length : next.first.start,
  );

  final constructor = RegExp('(const\\s+)?\\b$name\\s*\\(').firstMatch(body);
  if (constructor == null) {
    return PublicWidget(
      name: name,
      file: file.path,
      isConst: false,
      needsArguments: false,
    );
  }
  final parameters = _parenthesized(body, constructor.end).trim();
  final positional =
      parameters.isNotEmpty &&
      !parameters.startsWith('{') &&
      !parameters.startsWith('[');
  return PublicWidget(
    name: name,
    file: file.path,
    isConst: constructor[1] != null,
    needsArguments: positional || RegExp(r'\brequired\b').hasMatch(parameters),
  );
}

/// The text from [start], just after an opening parenthesis, to its match.
String _parenthesized(String source, int start) {
  var depth = 1;
  for (var i = start; i < source.length; i++) {
    final char = source[i];
    if (char == '(') depth++;
    if (char == ')' && --depth == 0) return source.substring(start, i);
  }
  return source.substring(start);
}
