import 'dart:convert';
import 'dart:io';

import 'package:fluttertemplates/fluttertemplates.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final fixtureRegistry = p.join(
  Directory.current.path,
  'test',
  'fixtures',
  'registry',
);

/// The outcome of one in-process run of the tool.
class Result {
  Result(this.code, this.out, this.err);

  final int code;
  final String out;
  final String err;
}

/// Records `flutter pub add` calls instead of running them.
class FakePubAdd {
  final calls = <List<String>>[];
  CliException? failure;

  /// Runs before [failure] is thrown, to act like a tool that writes, then
  /// fails.
  void Function(String root)? sideEffect;

  Future<void> call(String root, List<String> packages) async {
    sideEffect?.call(root);
    if (failure case final failure?) throw failure;
    calls.add(packages);
  }
}

Future<Result> runCli(
  List<String> args, {
  String? cwd,
  Map<String, String> environment = const {},
  http.Client? client,
  FakePubAdd? pubAdd,
  Stream<String>? input,
  bool useFixture = true,
}) async {
  final out = StringBuffer();
  final err = StringBuffer();
  final code = await run(
    [
      if (useFixture) ...['--registry', fixtureRegistry],
      ...args,
    ],
    context: CliContext(
      out: out,
      err: err,
      environment: environment,
      cwd: cwd ?? Directory.current.path,
      client: client,
      pubAdd: (pubAdd ?? FakePubAdd()).call,
      input: input ?? const Stream.empty(),
    ),
  );
  return Result(code, out.toString(), err.toString());
}

/// A throwaway directory, deleted after the test.
Directory tempDir() {
  final dir = Directory.systemTemp.createTempSync('fluttertemplates_test');
  addTearDown(() => dir.deleteSync(recursive: true));
  // macOS hands out /var, a symlink to /private/var; compare real paths.
  return Directory(dir.resolveSymbolicLinksSync());
}

/// Every file and directory under [dir], with file contents, for proving that
/// nothing changed, leftovers included.
Map<String, String> treeOf(Directory dir) => {
  for (final entity in dir.listSync(recursive: true))
    p.relative(entity.path, from: dir.path): entity is File
        ? entity.readAsStringSync()
        : '<directory>',
};

/// A throwaway copy of the fixture registry.
Directory registryCopy() {
  final dir = tempDir();
  for (final entity in Directory(fixtureRegistry).listSync(recursive: true)) {
    if (entity is! File) continue;
    final copy = File(
      p.join(dir.path, p.relative(entity.path, from: fixtureRegistry)),
    )..createSync(recursive: true);
    entity.copySync(copy.path);
  }
  return dir;
}

/// A copy of the fixture registry without any license information.
Directory unlicensedRegistry() {
  final dir = registryCopy();
  File(p.join(dir.path, 'LICENSE')).deleteSync();
  for (final file in dir.listSync(recursive: true).whereType<File>()) {
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    _dropLicense(json);
    for (final entry in json['widgets'] as List<dynamic>? ?? const []) {
      _dropLicense(entry as Map<String, dynamic>);
    }
    file.writeAsStringSync(jsonEncode(json));
  }
  return dir;
}

void _dropLicense(Map<String, dynamic> json) => json
  ..remove('license')
  ..remove('licenseUrl');

/// A minimal Flutter project, with [extraDependencies] as pubspec lines.
Directory flutterProject({String extraDependencies = ''}) {
  final dir = tempDir();
  File(p.join(dir.path, 'pubspec.yaml')).writeAsStringSync('''
name: demo_app
environment:
  sdk: ^3.8.0
dependencies:
  flutter:
    sdk: flutter
$extraDependencies
''');
  return dir;
}
