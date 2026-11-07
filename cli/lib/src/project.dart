import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'errors.dart';

/// The Flutter project a command runs in.
class FlutterProject {
  const FlutterProject({
    required this.root,
    required this.name,
    required this.dependencies,
    this.isWorkspaceMember = false,
  });

  /// Finds the nearest pubspec.yaml at or above [from].
  factory FlutterProject.find(String from) {
    var dir = p.normalize(p.absolute(from));
    while (true) {
      final pubspec = File(p.join(dir, 'pubspec.yaml'));
      if (pubspec.existsSync()) return FlutterProject._load(pubspec);
      final parent = p.dirname(dir);
      if (parent == dir) {
        throw CliException(
          'No pubspec.yaml found in $from or any parent directory.\n'
          'Run this command inside a Flutter project.',
        );
      }
      dir = parent;
    }
  }

  factory FlutterProject._load(File pubspec) {
    final Object? yaml;
    try {
      yaml = loadYaml(pubspec.readAsStringSync());
    } on YamlException catch (e) {
      throw CliException('Could not parse ${pubspec.path}: ${e.message}');
    } on FileSystemException catch (e) {
      throw CliException('Could not read ${pubspec.path}: ${e.message}');
    }
    final name = yaml is YamlMap ? yaml['name'] : null;
    if (yaml is! YamlMap || name is! String) {
      throw CliException('${pubspec.path} has no package name.');
    }
    final dependencies = yaml['dependencies'];
    final names = dependencies is YamlMap
        ? dependencies.keys.whereType<String>().toSet()
        : <String>{};
    if (!names.contains('flutter')) {
      throw CliException(
        '${pubspec.path} is not a Flutter project: it does not depend on the '
        'Flutter SDK.',
      );
    }
    return FlutterProject(
      root: pubspec.parent.path,
      name: name,
      dependencies: names,
      isWorkspaceMember: yaml['resolution'] == 'workspace',
    );
  }

  final String root;
  final String name;

  /// Names under `dependencies:`. Dev dependencies are left out on purpose:
  /// code under lib/ cannot rely on them.
  final Set<String> dependencies;

  /// Whether this package resolves with a pub workspace above it.
  final bool isWorkspaceMember;

  String get pubspecFile => p.join(root, 'pubspec.yaml');

  /// The lock file `flutter pub add` writes: a workspace shares one, at its
  /// root, which is the nearest lock file above a member.
  String get lockFile {
    final own = p.join(root, 'pubspec.lock');
    if (!isWorkspaceMember) return own;
    var dir = root;
    while (p.dirname(dir) != dir) {
      dir = p.dirname(dir);
      final candidate = p.join(dir, 'pubspec.lock');
      if (File(candidate).existsSync()) return candidate;
    }
    return own;
  }
}
