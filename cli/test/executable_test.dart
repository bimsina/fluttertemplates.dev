import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support.dart';

/// These run the real entry point, for what only a real process can show.
void main() {
  test('survives a reader that goes away', () async {
    final result = await Process.run('bash', [
      '-c',
      'set -o pipefail; '
          'dart run bin/fluttertemplates.dart --registry "$fixtureRegistry" '
          'list 2>&1 | head -1; echo "status: \${PIPESTATUS[0]}"',
    ]);

    expect(result.stdout, isNot(contains('Unhandled exception')));
    expect(result.stdout, contains('status: 0'));
  }, testOn: '!windows');

  test('restores the project when the real flutter tool fails', () async {
    final project = flutterProject();
    final lock = File(p.join(project.path, 'pubspec.lock'))
      ..writeAsStringSync('packages: {}\n');
    final before = treeOf(project);

    // Stands in for `flutter`: rewrites both files, then fails.
    final bin = tempDir();
    final flutter = File(p.join(bin.path, 'flutter'))
      ..writeAsStringSync('''
#!/bin/sh
echo "  broken: true" >> pubspec.yaml
echo rewritten > pubspec.lock
echo "version solving failed" >&2
exit 65
''');
    Process.runSync('chmod', ['+x', flutter.path]);

    final result = await Process.run(
      'dart',
      [
        p.join(Directory.current.path, 'bin', 'fluttertemplates.dart'),
        '--registry',
        fixtureRegistry,
        'add',
        'navigation/bottom_navigation/fancy_bar',
      ],
      workingDirectory: project.path,
      environment: {'PATH': '${bin.path}:${Platform.environment['PATH']}'},
    );

    expect(result.exitCode, 1);
    expect(result.stderr, contains('version solving failed'));
    expect(
      result.stderr,
      contains('pubspec.yaml and pubspec.lock were restored'),
    );
    expect(lock.readAsStringSync(), 'packages: {}\n');
    expect(treeOf(project), before);
  }, testOn: '!windows');

  test('reports errors on stderr with a non-zero exit code', () async {
    final result = await Process.run('dart', [
      'run',
      'bin/fluttertemplates.dart',
      '--registry',
      fixtureRegistry,
      'info',
      'auth/nope',
    ]);

    expect(result.exitCode, 1);
    expect(result.stdout, isEmpty);
    expect(result.stderr, contains('Unknown widget'));
  });
}
