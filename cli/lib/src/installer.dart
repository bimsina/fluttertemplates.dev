import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'errors.dart';
import 'models.dart';
import 'project.dart';
import 'public_widget.dart';

/// Runs `flutter pub add` in [projectRoot] for [packages], each in the
/// `name` or `name:constraint` form. Throws [CliException] on failure.
typedef PubAdd =
    Future<void> Function(String projectRoot, List<String> packages);

enum FileAction { create, overwrite, unchanged, conflict }

class PlannedFile {
  const PlannedFile({
    required this.widgetId,
    required this.relativePath,
    required this.absolutePath,
    required this.content,
    required this.action,
  });

  final String widgetId;

  /// Relative to the project root, for messages.
  final String relativePath;
  final String absolutePath;
  final String content;
  final FileAction action;
}

const licenseFileName = 'LICENSE';

/// Everything `add` is going to do, computed without touching the project.
class InstallPlan {
  const InstallPlan({
    required this.files,
    required this.packages,
    required this.warnings,
  });

  final List<PlannedFile> files;

  /// Packages to install, as arguments for `flutter pub add`.
  final List<String> packages;
  final List<String> warnings;

  List<PlannedFile> get conflicts => [
    for (final file in files)
      if (file.action == FileAction.conflict) file,
  ];
}

/// Resolves `--dir` against the project, refusing to leave it: copied code
/// needs the project's pubspec to resolve its packages.
String resolveInstallDir(FlutterProject project, String dir) {
  final resolved = p.normalize(p.join(project.root, dir));
  if (resolved != project.root && !p.isWithin(project.root, resolved)) {
    throw CliException('--dir must be inside the project: $dir');
  }
  return resolved;
}

/// Plans copying [widgets] into [installDir]. [licenseText], when there is one,
/// goes in a LICENSE file at the top of [installDir], under the same rules as
/// any other file, so an existing one that differs is a conflict.
InstallPlan planInstall({
  required FlutterProject project,
  required String installDir,
  required List<WidgetDetail> widgets,
  required bool force,
  String? licenseText,
}) {
  final files = <String, PlannedFile>{};
  final warnings = <String>[];

  void plan(String owner, String path, String content) {
    final target = _targetPath(installDir, owner, path);
    final earlier = files[target];
    if (earlier != null) {
      if (earlier.content == content) return;
      throw CliException(
        '$owner and ${earlier.widgetId} both provide $path with different '
        'content. Add them separately with different --dir values.',
      );
    }
    files[target] = PlannedFile(
      widgetId: owner,
      relativePath: p.relative(target, from: project.root),
      absolutePath: target,
      content: content,
      action: _actionFor(target, content, force),
    );
  }

  for (final widget in widgets) {
    warnings.addAll(checkImports(widget));
    for (final file in widget.files) {
      plan(widget.id, file.path, file.content);
    }
  }
  if (licenseText != null) {
    plan('the registry license', licenseFileName, licenseText);
  }

  final packages = <String, String>{};
  for (final widget in widgets) {
    for (final dep in widget.summary.dependencies) {
      if (project.dependencies.contains(dep.name)) continue;
      packages[dep.name] = _pubAddArgument(dep);
    }
  }

  return InstallPlan(
    files: files.values.toList(),
    packages: packages.values.toList(),
    warnings: warnings,
  );
}

/// Registry paths come from the network, so one that escapes [installDir] must
/// not reach the file system.
String _targetPath(String installDir, String id, String path) {
  final parts = path.split('/');
  final unsafe =
      path.isEmpty ||
      path.contains(r'\') ||
      path.contains(':') ||
      p.posix.isAbsolute(path) ||
      parts.any((part) => part.isEmpty || part == '.' || part == '..');
  if (unsafe) {
    throw CliException('Refusing to install $id: unsafe file path "$path".');
  }
  return p.joinAll([installDir, ...parts]);
}

FileAction _actionFor(String target, String content, bool force) {
  final existing = File(target);
  if (!existing.existsSync()) return FileAction.create;
  final List<int> current;
  try {
    current = existing.readAsBytesSync();
  } on FileSystemException catch (e) {
    throw CliException('Could not read $target: ${e.message}');
  }
  final wanted = utf8.encode(content);
  if (_sameBytes(current, wanted)) return FileAction.unchanged;
  return force ? FileAction.overwrite : FileAction.conflict;
}

bool _sameBytes(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

final _safeName = RegExp(r'^[a-z][a-z0-9_]*$');
final _plainVersion = RegExp(r'^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.+-]+)?$');
final _caretVersion = RegExp(r'^\^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.+-]+)?$');

/// The registry records the exact version the library was tested with. Users
/// get a caret on it, so that a pin does not fight their other packages.
/// Anything unusual falls back to the latest version; this value ends up on a
/// command line, which on Windows goes through a shell.
String _pubAddArgument(WidgetDependency dep) {
  if (!_safeName.hasMatch(dep.name)) {
    throw CliException('Registry lists an invalid package: "${dep.name}".');
  }
  if (_plainVersion.hasMatch(dep.version)) return '${dep.name}:^${dep.version}';
  if (_caretVersion.hasMatch(dep.version)) return '${dep.name}:${dep.version}';
  return dep.name;
}

final _directive = RegExp(
  r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

/// Reports imports of [widget] that will not resolve once it is copied:
/// relative imports leaving the set of copied files, and packages the registry
/// does not list as dependencies.
List<String> checkImports(WidgetDetail widget) {
  final paths = {for (final file in widget.files) file.path};
  final packages = {
    'flutter',
    for (final dep in widget.summary.dependencies) dep.name,
  };
  final problems = <String>{};
  for (final file in widget.files) {
    for (final match in _directive.allMatches(file.content)) {
      final uri = match[1]!;
      if (uri.startsWith('dart:')) continue;
      if (uri.startsWith('package:')) {
        final package = uri.substring('package:'.length).split('/').first;
        if (!packages.contains(package)) {
          problems.add(
            '${file.path} imports $uri, which is not a listed '
            'dependency.',
          );
        }
        continue;
      }
      final target = p.posix.normalize(
        p.posix.join(p.posix.dirname(file.path), uri),
      );
      if (!paths.contains(target)) {
        problems.add(
          '${file.path} imports $uri, which is not part of '
          '${widget.id}.',
        );
      }
    }
  }
  return problems.toList();
}

/// Applies [plan] as a unit: when this throws, the pubspec, the lock file and
/// every file of the plan are as they were, or the message says what is not.
///
/// New content is staged first, so that a full disk shows up before anything
/// has changed. Packages come next, because `flutter pub add` can fail for
/// reasons out of our hands and may have rewritten the pubspec by then. Moving
/// the staged files into place is last, and each move can be undone.
///
/// Returns warnings about an install that otherwise went fine.
Future<List<String>> applyInstall(
  InstallPlan plan,
  FlutterProject project,
  PubAdd pubAdd,
) async {
  final writes = [
    for (final file in plan.files)
      if (file.action == FileAction.create ||
          file.action == FileAction.overwrite)
        file,
  ];
  if (writes.isEmpty && plan.packages.isEmpty) return const [];

  final transaction = await _Transaction.begin(project.root);
  var pubStarted = false;
  try {
    for (final file in writes) {
      await _writing(file.relativePath, () => transaction.stage(file));
    }
    if (plan.packages.isNotEmpty) {
      for (final path in [project.pubspecFile, project.lockFile]) {
        await _writing(path, () => transaction.snapshot(path));
      }
      pubStarted = true;
      await pubAdd(project.root, plan.packages);
    }
    for (final file in writes) {
      await _writing(file.relativePath, () => transaction.commit(file));
    }
  } on Object catch (e) {
    final problems = await transaction.rollback();
    if (e is! CliException) rethrow;
    throw CliException('${e.message}\n${_outcome(problems, pubStarted)}');
  }
  final leftover = await transaction.discard();
  return [?leftover];
}

Future<void> _writing(String path, Future<void> Function() action) async {
  try {
    await action();
  } on FileSystemException catch (e) {
    throw CliException('Could not write $path: ${e.message}');
  }
}

String _outcome(List<String> problems, bool pubStarted) {
  if (problems.isNotEmpty) {
    return 'The project could not be fully restored:\n'
        '${problems.map((problem) => '  $problem').join('\n')}';
  }
  if (!pubStarted) return 'Nothing was changed.';
  return 'pubspec.yaml and pubspec.lock were restored, and no files were '
      'copied.';
}

/// Changes to the project that can be undone until [discard]. Originals and
/// new content wait in a directory inside the project, as a rename is only
/// atomic within one file system.
class _Transaction {
  _Transaction._(this._staging);

  static Future<_Transaction> begin(String projectRoot) async {
    try {
      final staging = await Directory(
        projectRoot,
      ).createTemp('.fluttertemplates-');
      return _Transaction._(staging);
    } on FileSystemException catch (e) {
      throw CliException(
        'Could not write to $projectRoot: ${e.message}\nNothing was changed.',
      );
    }
  }

  final Directory _staging;
  final _staged = <PlannedFile, File>{};

  /// Run newest first by [rollback].
  final _undo = <Future<void> Function()>[];
  var _lastName = 0;

  String _stagingPath() => p.join(_staging.path, '${_lastName++}');

  /// Writes [file] to the staging directory. Touches nothing else.
  Future<void> stage(PlannedFile file) async {
    final staged = File(_stagingPath());
    await staged.writeAsString(file.content, flush: true);
    _staged[file] = staged;
  }

  /// Remembers [path], which may not exist, for [rollback] to put back.
  Future<void> snapshot(String path) async {
    final file = File(path);
    final copy = await file.exists() ? await file.copy(_stagingPath()) : null;
    _undo.add(() async {
      if (copy == null) {
        if (await file.exists()) await file.delete();
      } else if (!await _sameContent(file, copy)) {
        await copy.rename(path);
      }
    });
  }

  /// Moves the staged [file] to its target.
  Future<void> commit(PlannedFile file) async {
    final target = File(file.absolutePath);
    await _createDirectories(target.parent);
    if (await target.exists()) {
      final original = await target.rename(_stagingPath());
      _undo.add(() => original.rename(target.path));
    }
    await _staged[file]!.rename(target.path);
    _undo.add(target.delete);
  }

  Future<void> _createDirectories(Directory directory) async {
    final missing = <Directory>[];
    for (var dir = directory; !await dir.exists(); dir = dir.parent) {
      missing.add(dir);
    }
    // Deepest last, so it is the first to go. `create` can stop halfway, and a
    // path may turn out to be a file, so only what exists is removed.
    for (final dir in missing.reversed) {
      _undo.add(() async {
        if (await dir.exists()) await dir.delete();
      });
    }
    await directory.create(recursive: true);
  }

  /// Undoes everything and returns what could not be undone. The staging
  /// directory then stays, because it holds the originals.
  Future<List<String>> rollback() async {
    final problems = <String>[];
    for (final undo in _undo.reversed) {
      try {
        await undo();
      } on FileSystemException catch (e) {
        problems.add('${e.path}: ${e.message}');
      }
    }
    if (problems.isNotEmpty) {
      problems.add('Your original files are in ${_staging.path}');
    } else {
      final leftover = await discard();
      if (leftover != null) problems.add(leftover);
    }
    return problems;
  }

  /// Removes the staging directory, or returns why it could not.
  Future<String?> discard() async {
    try {
      await _staging.delete(recursive: true);
      return null;
    } on FileSystemException catch (e) {
      return 'Could not remove ${_staging.path}: ${e.message}';
    }
  }
}

Future<bool> _sameContent(File a, File b) async {
  if (!await a.exists()) return false;
  return _sameBytes(await a.readAsBytes(), await b.readAsBytes());
}

/// The import to use for [widget] installed under [installDir], or null if
/// that directory is outside lib/ and has no package URI.
String? packageImport(
  FlutterProject project,
  String installDir,
  PublicWidget widget,
) {
  final lib = p.join(project.root, 'lib');
  final target = p.joinAll([installDir, ...widget.file.split('/')]);
  if (!p.isWithin(lib, target)) return null;
  final relative = p.split(p.relative(target, from: lib)).join('/');
  return "import 'package:${project.name}/$relative';";
}

/// Default [PubAdd], running the `flutter` tool found on the PATH.
Future<void> flutterPubAdd(String projectRoot, List<String> packages) async {
  final ProcessResult result;
  try {
    result = await Process.run(
      'flutter',
      ['pub', 'add', ...packages],
      workingDirectory: projectRoot,
      runInShell: Platform.isWindows,
    );
  } on ProcessException {
    throw CliException(
      'Could not run "flutter". Is the Flutter SDK on your PATH?',
    );
  }
  if (result.exitCode != 0) {
    throw CliException(
      '"flutter pub add ${packages.join(' ')}" failed.\n'
              '${result.stderr}${result.stdout}'
          .trimRight(),
    );
  }
}
