import 'dart:io';

import 'package:fluttertemplates/fluttertemplates.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support.dart';

void main() {
  File fileIn(Directory project, String path) =>
      File(p.joinAll([project.path, ...path.split('/')]));

  List<String> filesUnder(Directory dir) => [
    for (final entity in dir.listSync(recursive: true))
      if (entity is File) p.relative(entity.path, from: dir.path),
  ]..sort();

  test('writes the file and prints the import and class to use', () async {
    final project = flutterProject();
    final result = await runCli([
      'add',
      'auth/signup_terms',
    ], cwd: project.path);

    expect(result.code, 0, reason: result.err);
    final written = fileIn(
      project,
      'lib/fluttertemplates/auth/signup_terms.dart',
    );
    expect(written.readAsStringSync(), contains('class SignupTerms'));
    expect(
      result.out,
      contains('created: lib/fluttertemplates/auth/signup_terms.dart'),
    );
    expect(
      result.out,
      contains(
        "import 'package:demo_app/fluttertemplates/auth/signup_terms.dart';",
      ),
    );
    expect(result.out, contains('const SignupTerms()'));
  });

  test('works from a subdirectory of the project', () async {
    final project = flutterProject();
    final nested = Directory(p.join(project.path, 'lib', 'src'))
      ..createSync(recursive: true);
    final result = await runCli(['add', 'auth/login_screen'], cwd: nested.path);

    expect(result.code, 0, reason: result.err);
    expect(
      fileIn(
        project,
        'lib/fluttertemplates/auth/login_screen.dart',
      ).existsSync(),
      isTrue,
    );
  });

  test('keeps every relative import of a template valid', () async {
    final project = flutterProject();
    final result = await runCli(['add', 'templates/shop'], cwd: project.path);
    expect(result.code, 0, reason: result.err);
    expect(result.err, isEmpty);

    final root = Directory(p.join(project.path, 'lib', 'fluttertemplates'));
    expect(filesUnder(root), [
      'LICENSE',
      'templates/shop/main.dart',
      'templates/shop/models/product.dart',
      'templates/shop/screens/home_screen.dart',
      'templates/shop/widgets/product_tile.dart',
    ]);

    var relativeImports = 0;
    final directive = RegExp(r"^import '([^:']+)';", multiLine: true);
    final dartFiles = root
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in dartFiles) {
      for (final match in directive.allMatches(file.readAsStringSync())) {
        relativeImports++;
        final target = p.normalize(p.join(file.parent.path, match[1]!));
        expect(File(target).existsSync(), isTrue, reason: match[0]);
      }
    }
    expect(relativeImports, 4);
    expect(result.out, contains('runApp(const ShopApp());'));
  });

  test('honours --dir', () async {
    final project = flutterProject();
    final result = await runCli([
      'add',
      'auth/login_screen',
      '--dir',
      'lib/ui/vendor',
    ], cwd: project.path);

    expect(result.code, 0, reason: result.err);
    expect(
      fileIn(project, 'lib/ui/vendor/auth/login_screen.dart').existsSync(),
      isTrue,
    );
    expect(
      result.out,
      contains('package:demo_app/ui/vendor/auth/login_screen.dart'),
    );
  });

  test('a --dir outside lib/ has no package import to offer', () async {
    final project = flutterProject();
    final result = await runCli([
      'add',
      'auth/login_screen',
      '--dir',
      'tool/screens',
    ], cwd: project.path);

    expect(result.code, 0, reason: result.err);
    expect(result.out, isNot(contains('package:demo_app')));
    expect(result.out, contains('relative path'));
  });

  test('refuses a --dir outside the project', () async {
    final project = flutterProject();
    final result = await runCli([
      'add',
      'auth/login_screen',
      '--dir',
      '../elsewhere',
    ], cwd: project.path);

    expect(result.code, 1);
    expect(result.err, contains('inside the project'));
  });

  group('conflicts', () {
    late Directory project;
    late File existing;

    setUp(() {
      project = flutterProject();
      existing = fileIn(project, 'lib/fluttertemplates/auth/login_screen.dart')
        ..createSync(recursive: true)
        ..writeAsStringSync('// my edits\n');
    });

    test('never overwrites, and writes nothing at all', () async {
      final pubAdd = FakePubAdd();
      final result = await runCli(
        ['add', 'navigation/bottom_navigation/fancy_bar', 'auth/login_screen'],
        cwd: project.path,
        pubAdd: pubAdd,
      );

      expect(result.code, 1);
      expect(
        result.err,
        contains('lib/fluttertemplates/auth/login_screen.dart'),
      );
      expect(result.err, contains('--force'));
      expect(existing.readAsStringSync(), '// my edits\n');
      expect(
        fileIn(
          project,
          'lib/fluttertemplates/navigation/bottom_nav/fancy_bar.dart',
        ).existsSync(),
        isFalse,
        reason: 'the other widget must not be half installed',
      );
      expect(pubAdd.calls, isEmpty);
    });

    test('--force overwrites', () async {
      final result = await runCli([
        'add',
        'auth/login_screen',
        '--force',
      ], cwd: project.path);

      expect(result.code, 0, reason: result.err);
      expect(existing.readAsStringSync(), contains('class LoginScreen'));
      expect(result.out, contains('overwrote: '));
    });

    test('adding the same widget twice is not a conflict', () async {
      existing.deleteSync();
      await runCli(['add', 'auth/login_screen'], cwd: project.path);
      final again = await runCli([
        'add',
        'auth/login_screen',
      ], cwd: project.path);

      expect(again.code, 0, reason: again.err);
      expect(again.out, contains('unchanged: '));
    });
  });

  group('--dry-run', () {
    test('changes nothing and shows the plan', () async {
      final project = flutterProject();
      final pubAdd = FakePubAdd();
      final before = filesUnder(project);
      final result = await runCli(
        ['add', 'navigation/bottom_navigation/fancy_bar', '--dry-run'],
        cwd: project.path,
        pubAdd: pubAdd,
      );

      expect(result.code, 0, reason: result.err);
      expect(filesUnder(project), before);
      expect(pubAdd.calls, isEmpty);
      expect(
        result.out,
        contains(
          'would create: lib/fluttertemplates/navigation/bottom_nav/fancy_bar.dart',
        ),
      );
      expect(
        result.out,
        contains('would run: flutter pub add salomon_bottom_bar:^3.3.2'),
      );
    });

    test('still reports conflicts', () async {
      final project = flutterProject();
      fileIn(project, 'lib/fluttertemplates/auth/login_screen.dart')
        ..createSync(recursive: true)
        ..writeAsStringSync('// mine\n');
      final result = await runCli([
        'add',
        'auth/login_screen',
        '--dry-run',
      ], cwd: project.path);

      expect(result.code, 1);
      expect(result.err, contains('login_screen.dart'));
    });
  });

  group('dependencies', () {
    const id = 'navigation/bottom_navigation/fancy_bar';

    test('installs what is missing', () async {
      final project = flutterProject();
      final pubAdd = FakePubAdd();
      final result = await runCli(
        ['add', id],
        cwd: project.path,
        pubAdd: pubAdd,
      );

      expect(result.code, 0, reason: result.err);
      expect(pubAdd.calls, [
        ['salomon_bottom_bar:^3.3.2'],
      ]);
    });

    test('leaves alone what is already there', () async {
      final project = flutterProject(
        extraDependencies: '  salomon_bottom_bar: ^3.0.0',
      );
      final pubAdd = FakePubAdd();
      await runCli(['add', id], cwd: project.path, pubAdd: pubAdd);

      expect(pubAdd.calls, isEmpty);
    });

    test('a dev dependency does not count', () async {
      final project = flutterProject(
        extraDependencies: 'dev_dependencies:\n  salomon_bottom_bar: ^3.0.0',
      );
      final pubAdd = FakePubAdd();
      await runCli(['add', id], cwd: project.path, pubAdd: pubAdd);

      expect(pubAdd.calls, hasLength(1));
    });

    test('a failed install writes no files', () async {
      final project = flutterProject();
      final pubAdd = FakePubAdd()..failure = CliException('pub said no');
      final result = await runCli(
        ['add', id],
        cwd: project.path,
        pubAdd: pubAdd,
      );

      expect(result.code, 1);
      expect(result.err, contains('pub said no'));
      expect(Directory(p.join(project.path, 'lib')).existsSync(), isFalse);
    });
  });

  group('LICENSE', () {
    const installed = 'lib/fluttertemplates/LICENSE';

    File registryLicense() => File(p.join(fixtureRegistry, 'LICENSE'));

    test('is written once at the top of --dir, from the registry', () async {
      final project = flutterProject();
      final result = await runCli([
        'add',
        'auth/login_screen',
        'auth/signup_terms',
        '--dir',
        'lib/vendor',
      ], cwd: project.path);

      expect(result.code, 0, reason: result.err);
      expect(
        fileIn(project, 'lib/vendor/LICENSE').readAsStringSync(),
        registryLicense().readAsStringSync(),
      );
      expect(
        'created: lib/vendor/LICENSE'.allMatches(result.out),
        hasLength(1),
      );
      expect(fileIn(project, 'lib/vendor/auth/LICENSE').existsSync(), isFalse);
    });

    test('an identical one is left alone', () async {
      final project = flutterProject();
      await runCli(['add', 'auth/login_screen'], cwd: project.path);
      final result = await runCli([
        'add',
        'auth/signup_terms',
      ], cwd: project.path);

      expect(result.code, 0, reason: result.err);
      expect(result.out, contains('unchanged: $installed'));
    });

    test('a different one is a conflict, and writes nothing', () async {
      final project = flutterProject();
      final mine = fileIn(project, installed)
        ..createSync(recursive: true)
        ..writeAsStringSync('my terms\n');
      final before = treeOf(project);
      final result = await runCli([
        'add',
        'auth/login_screen',
      ], cwd: project.path);

      expect(result.code, 1);
      expect(result.err, contains(installed));
      expect(mine.readAsStringSync(), 'my terms\n');
      expect(treeOf(project), before);
    });

    test('--force replaces a different one', () async {
      final project = flutterProject();
      final mine = fileIn(project, installed)
        ..createSync(recursive: true)
        ..writeAsStringSync('my terms\n');
      final result = await runCli([
        'add',
        'auth/login_screen',
        '--force',
      ], cwd: project.path);

      expect(result.code, 0, reason: result.err);
      expect(result.out, contains('overwrote: $installed'));
      expect(mine.readAsStringSync(), registryLicense().readAsStringSync());
    });

    test('--dry-run reports it and writes nothing', () async {
      final project = flutterProject();
      final before = treeOf(project);
      final result = await runCli([
        'add',
        'auth/login_screen',
        '--dry-run',
      ], cwd: project.path);

      expect(result.out, contains('would create: $installed'));
      expect(treeOf(project), before);
    });

    test('a declared license that cannot be fetched stops the add', () async {
      final registry = registryCopy();
      File(p.join(registry.path, 'LICENSE')).deleteSync();
      final project = flutterProject();
      final before = treeOf(project);
      final result = await runCli(
        ['--registry', registry.path, 'add', 'auth/login_screen'],
        cwd: project.path,
        useFixture: false,
      );

      expect(result.code, 1);
      expect(result.err, contains('has no LICENSE'));
      expect(result.err, contains('Nothing was changed'));
      expect(treeOf(project), before);
    });

    test('a registry that declares none only gets a warning', () async {
      final project = flutterProject();
      final result = await runCli(
        ['--registry', unlicensedRegistry().path, 'add', 'auth/login_screen'],
        cwd: project.path,
        useFixture: false,
      );

      expect(result.code, 0, reason: result.err);
      expect(result.err, contains('declares no license'));
      expect(fileIn(project, installed).existsSync(), isFalse);
    });
  });

  group('all or nothing', () {
    const id = 'navigation/bottom_navigation/fancy_bar';
    const lock = 'packages: {}\n';

    /// Rewrites the pubspec and lock file the way `flutter pub add` does.
    void writePubFiles(String root) {
      File(p.join(root, 'pubspec.yaml')).writeAsStringSync(
        '  salomon_bottom_bar: ^3.3.2\n',
        mode: FileMode.append,
      );
      File(p.join(root, 'pubspec.lock')).writeAsStringSync('rewritten\n');
    }

    FakePubAdd writesThenFails() => FakePubAdd()
      ..sideEffect = writePubFiles
      ..failure = CliException('pub said no');

    test('a pub add that writes, then fails, restores both files', () async {
      final project = flutterProject();
      fileIn(project, 'pubspec.lock').writeAsStringSync(lock);
      final before = treeOf(project);
      final result = await runCli(
        ['add', id],
        cwd: project.path,
        pubAdd: writesThenFails(),
      );

      expect(result.code, 1);
      expect(result.err, contains('pub said no'));
      expect(result.err, contains('restored'));
      expect(treeOf(project), before);
    });

    test('a lock file that pub add created is removed again', () async {
      final project = flutterProject();
      final before = treeOf(project);
      final result = await runCli(
        ['add', id],
        cwd: project.path,
        pubAdd: writesThenFails(),
      );

      expect(result.code, 1);
      expect(treeOf(project), before);
    });

    test('a workspace member gets the shared lock file restored', () async {
      final workspace = tempDir();
      File(p.join(workspace.path, 'pubspec.lock')).writeAsStringSync(lock);
      final member = Directory(p.join(workspace.path, 'app'))..createSync();
      File(p.join(member.path, 'pubspec.yaml')).writeAsStringSync('''
name: demo_app
resolution: workspace
dependencies:
  flutter:
    sdk: flutter
''');
      final before = treeOf(workspace);
      final pubAdd = FakePubAdd()
        ..sideEffect = (root) {
          File(
            p.join(root, 'pubspec.yaml'),
          ).writeAsStringSync('# changed\n', mode: FileMode.append);
          File(
            p.join(workspace.path, 'pubspec.lock'),
          ).writeAsStringSync('rewritten\n');
        }
        ..failure = CliException('pub said no');
      final result = await runCli(
        ['add', id],
        cwd: member.path,
        pubAdd: pubAdd,
      );

      expect(result.code, 1);
      expect(treeOf(workspace), before);
    });

    group('a write that fails partway', () {
      // Files are moved into place in order, so main.dart of templates/shop is
      // already there when the second one fails.
      const main = 'lib/fluttertemplates/templates/shop/main.dart';
      const blocked = 'lib/fluttertemplates/templates/shop/models';

      test('undoes the files before it', () async {
        final project = flutterProject();
        fileIn(project, blocked)
          ..createSync(recursive: true)
          ..writeAsStringSync('a file where a directory has to go\n');
        final before = treeOf(project);
        final result = await runCli([
          'add',
          'templates/shop',
        ], cwd: project.path);

        expect(result.code, 1);
        expect(result.err, contains('Could not write'));
        expect(treeOf(project), before);
      });

      test('removes the directories it created', () async {
        final project = flutterProject();
        // A directory in the place of the last file makes its move fail.
        Directory(
          p.join(
            project.path,
            'lib/fluttertemplates/templates/shop/widgets/product_tile.dart',
            'keep',
          ),
        ).createSync(recursive: true);
        final before = treeOf(project);
        final result = await runCli([
          'add',
          'templates/shop',
        ], cwd: project.path);

        expect(result.code, 1);
        expect(treeOf(project), before);
      });

      test('puts overwritten files back', () async {
        final project = flutterProject();
        fileIn(project, main)
          ..createSync(recursive: true)
          ..writeAsStringSync('// my edits\n');
        fileIn(project, blocked).writeAsStringSync('in the way\n');
        final before = treeOf(project);
        final result = await runCli([
          'add',
          'templates/shop',
          '--force',
        ], cwd: project.path);

        expect(result.code, 1);
        expect(treeOf(project), before);
      });

      test('restores what a successful pub add changed', () async {
        final project = flutterProject();
        fileIn(project, 'pubspec.lock').writeAsStringSync(lock);
        fileIn(project, 'lib/fluttertemplates/navigation')
          ..createSync(recursive: true)
          ..writeAsStringSync('in the way\n');
        final before = treeOf(project);
        final pubAdd = FakePubAdd()..sideEffect = writePubFiles;
        final result = await runCli(
          ['add', id],
          cwd: project.path,
          pubAdd: pubAdd,
        );

        expect(result.code, 1);
        expect(pubAdd.calls, hasLength(1));
        expect(result.err, contains('restored'));
        expect(treeOf(project), before);
      });
    });

    test('a project it cannot write to stays as it was', () async {
      final project = flutterProject();
      final before = treeOf(project);
      Process.runSync('chmod', ['555', project.path]);
      addTearDown(() => Process.runSync('chmod', ['755', project.path]));
      final result = await runCli([
        'add',
        'auth/login_screen',
      ], cwd: project.path);
      if (result.code == 0) {
        markTestSkipped('Running as a user that ignores permissions.');
        return;
      }

      expect(result.err, contains('Nothing was changed'));
      expect(treeOf(project), before);
    }, testOn: '!windows');

    test('leaves nothing of its own behind on success', () async {
      final project = flutterProject();
      final result = await runCli(['add', 'templates/shop'], cwd: project.path);

      expect(result.code, 0, reason: result.err);
      expect(
        project.listSync().map((entity) => p.basename(entity.path)),
        unorderedEquals(['pubspec.yaml', 'lib']),
      );
    });
  });

  group('usage snippet', () {
    test('drops const for a non-const constructor', () async {
      final project = flutterProject();
      final result = await runCli([
        'add',
        'navigation/bottom_navigation/fancy_bar',
      ], cwd: project.path);

      expect(result.out, contains('home: FancyBar(),'));
    });

    test('does not pretend required arguments are optional', () async {
      final project = flutterProject();
      final result = await runCli([
        'add',
        'pricing/price_card',
      ], cwd: project.path);

      expect(result.out, contains('Use PriceCard from'));
      expect(result.out, isNot(contains('PriceCard()')));
    });
  });

  group('refuses', () {
    test('outside a project', () async {
      final result = await runCli([
        'add',
        'auth/login_screen',
      ], cwd: tempDir().path);

      expect(result.code, 1);
      expect(result.err, contains('No pubspec.yaml found'));
    });

    test('a pure Dart package', () async {
      final dir = tempDir();
      File(p.join(dir.path, 'pubspec.yaml')).writeAsStringSync('name: tool\n');
      final result = await runCli(['add', 'auth/login_screen'], cwd: dir.path);

      expect(result.code, 1);
      expect(result.err, contains('not a Flutter project'));
    });

    test('a mistyped id, suggesting the right one, writing nothing', () async {
      final project = flutterProject();
      final result = await runCli([
        'add',
        'auth/login_screen',
        'auth/signup_term',
      ], cwd: project.path);

      expect(result.code, 1);
      expect(result.err, contains('Unknown widget "auth/signup_term"'));
      expect(result.err, contains('auth/signup_terms'));
      expect(Directory(p.join(project.path, 'lib')).existsSync(), isFalse);
    });

    for (final id in ['broken/escape', 'broken/absolute']) {
      test('registry paths that leave --dir: $id', () async {
        final project = flutterProject();
        final result = await runCli(['add', id], cwd: project.path);

        expect(result.code, 1);
        expect(result.err, contains('unsafe file path'));
        expect(
          File(p.join(project.parent.path, 'outside.dart')).existsSync(),
          isFalse,
        );
        expect(
          File('/tmp/fluttertemplates_absolute.dart').existsSync(),
          isFalse,
        );
      });
    }
  });

  test('warns about imports that cannot resolve after copying', () async {
    final project = flutterProject();
    final result = await runCli(['add', 'broken/dangling'], cwd: project.path);

    expect(result.err, contains('../shared/helpers.dart'));
    expect(result.err, contains('package:core/theme.dart'));
  });
}
