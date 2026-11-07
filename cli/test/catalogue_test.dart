import 'dart:io';

import 'package:fluttertemplates/fluttertemplates.dart';
import 'package:fluttertemplates/src/models.dart';
import 'package:fluttertemplates/src/public_widget.dart';
import 'package:fluttertemplates/src/search.dart';
import 'package:fluttertemplates/src/suggest.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'support.dart';

void main() {
  group('list', () {
    test('groups everything by category', () async {
      final result = await runCli(['list']);

      expect(result.code, 0, reason: result.err);
      expect(result.out, contains('Authentication (2)'));
      expect(result.out, contains('auth/signup_terms'));
      expect(result.out, contains('templates/shop'));
    });

    test('--category filters', () async {
      final result = await runCli(['list', '--category', 'auth']);

      expect(result.out, contains('auth/login_screen'));
      expect(result.out, isNot(contains('templates/shop')));
    });

    test('an unknown category suggests a close one', () async {
      final result = await runCli(['list', '--category', 'pricin']);

      expect(result.code, 1);
      expect(result.err, contains('Unknown category "pricin"'));
      expect(result.err, contains('pricing'));
    });
  });

  group('search', () {
    WidgetSummary widget(
      String id, {
      String title = 'Untitled',
      String description = '',
      String category = 'misc',
      List<String> flutterWidgets = const [],
    }) => WidgetSummary(
      id: id,
      title: title,
      description: description,
      category: category,
      categoryTitle: category,
      url: '',
      loc: 0,
      flutterWidgets: flutterWidgets,
      dependencies: const [],
    );

    List<String> ids(Iterable<WidgetSummary> widgets, String query) => [
      for (final hit in searchWidgets(widgets, query)) hit.widget.id,
    ];

    test('ranks a title above a category, widget or description', () {
      final widgets = [
        widget('description', description: 'Has a login button.'),
        widget('widget', flutterWidgets: ['Login']),
        widget('category', category: 'login'),
        widget('title', title: 'Login'),
      ];

      final ranked = ids(widgets, 'login');
      expect(ranked.first, 'title');
      expect(ranked.last, 'description');
      expect(ranked, hasLength(4));
    });

    test('finds a Flutter widget, ignoring case', () {
      final widgets = [
        widget('a', flutterWidgets: ['NavigationRail']),
        widget('b', flutterWidgets: ['Card']),
      ];

      expect(ids(widgets, 'navigationrail'), ['a']);
    });

    test('a word found everywhere does not outweigh a rare one', () {
      final widgets = [
        widget('flutter', title: 'Flutter Flutter'),
        widget('login', title: 'Login', description: 'A Flutter page.'),
        for (var i = 0; i < 20; i++)
          widget('other$i', description: 'A Flutter page.'),
      ];

      expect(ids(widgets, 'flutter login').first, 'login');
    });

    test('matching all words beats one strong match', () {
      final widgets = [
        widget('one', title: 'Calendar'),
        widget('both', description: 'A calendar with an agenda.'),
        widget('agenda', title: 'Other', description: 'An agenda.'),
      ];

      expect(ids(widgets, 'calendar agenda').first, 'both');
    });

    test('a strong match on the rarer word beats two weak matches', () {
      final widgets = [
        widget('weak', category: 'forms', description: 'Back to login'),
        widget('strong', title: 'Login Screen', category: 'auth'),
        for (var i = 0; i < 10; i++) widget('forms$i', category: 'forms'),
      ];

      expect(ids(widgets, 'login form').first, 'strong');
    });

    test('drops passing matches when there are real ones', () {
      final widgets = [
        widget('real', title: 'Bottom Bar', description: 'A bottom bar.'),
        widget('passing', flutterWidgets: ['AppBar']),
      ];

      expect(ids(widgets, 'bottom bar'), ['real']);
      expect(ids(widgets.sublist(1), 'bar'), ['passing']);
    });

    test('handles plurals both ways', () {
      final widgets = [widget('chart', title: 'Line Chart')];

      expect(ids(widgets, 'charts'), ['chart']);
      expect(ids([widget('c', title: 'Charts')], 'chart'), ['c']);
    });

    test('no match is an empty result, on the command line too', () async {
      expect(ids([widget('a', title: 'Card')], 'zzzz'), isEmpty);

      final result = await runCli(['search', 'zzzz']);
      expect(result.code, 0);
      expect(result.out, contains('No widgets match'));
    });

    test('joins words and ranks real fixture data', () async {
      final result = await runCli(['search', 'login', 'screen']);

      expect(result.out.split('\n').first, startsWith('auth/login_screen'));
    });

    test('--limit caps the output and says so', () async {
      final result = await runCli(['search', 'flutter', '--limit', '1']);

      expect(
        RegExp(r'^\S+/\S+  ', multiLine: true).allMatches(result.out),
        hasLength(1),
      );
      expect(result.out, contains('Showing 1 of'));
    });
  });

  group('info', () {
    test('shows the license', () async {
      final result = await runCli(['info', 'auth/login_screen']);

      expect(
        result.out,
        contains('License:  MIT (https://fluttertemplates.dev/r/LICENSE)'),
      );
    });

    test('says when a registry declares no license', () async {
      final result = await runCli([
        '--registry',
        unlicensedRegistry().path,
        'info',
        'auth/login_screen',
      ], useFixture: false);

      expect(result.code, 0, reason: result.err);
      expect(result.out, contains('License:  not declared by this registry'));
    });

    test('suggests adding from the registry in use', () async {
      final result = await runCli(['info', 'auth/login_screen']);

      expect(
        result.out,
        contains(
          'Add it: fluttertemplates add auth/login_screen '
          '--registry $fixtureRegistry',
        ),
      );
    });

    test('shows the facts, including the public class', () async {
      final result = await runCli([
        'info',
        'navigation/bottom_navigation/fancy_bar',
      ]);

      expect(result.code, 0, reason: result.err);
      expect(result.out, contains('Fancy Bar'));
      expect(result.out, contains('Widget:   FancyBar'));
      expect(result.out, contains('salomon_bottom_bar 3.3.2'));
      expect(result.out, contains('navigation/bottom_nav/fancy_bar.dart'));
    });

    test('an unknown id suggests close ones', () async {
      final result = await runCli(['info', 'signup_terms']);

      expect(result.code, 1);
      expect(result.err, contains('Did you mean'));
      expect(result.err, contains('auth/signup_terms'));
    });

    test('nothing close means no suggestion', () async {
      final result = await runCli(['info', 'qqqqqqqqqq']);

      expect(result.code, 1);
      expect(result.err, isNot(contains('Did you mean')));
    });
  });

  group('closeMatches', () {
    const ids = ['auth/signup_terms', 'auth/login', 'forms/login'];

    test('catches a typo in the whole id', () {
      expect(closeMatches('auth/sigup_terms', ids).first, 'auth/signup_terms');
    });

    test('catches the right name in the wrong folder', () {
      expect(closeMatches('x/signup_terms', ids), ['auth/signup_terms']);
    });

    test('ignores case', () {
      expect(closeMatches('AUTH/LOGIN', ids).first, 'auth/login');
    });
  });

  group('findPublicWidget', () {
    WidgetDetail detail(String id, Map<String, String> files) => WidgetDetail(
      summary: WidgetSummary.fromJson({'id': id}),
      files: [
        for (final MapEntry(:key, :value) in files.entries)
          WidgetFile(path: key, content: value),
      ],
    );

    const stateless = 'extends StatelessWidget {';

    test('prefers the class named after the file over the first one', () {
      final found = findPublicWidget(
        detail('x/my_page', {
          'x/my_page.dart':
              'class Helper $stateless}\nclass MyPage $stateless}',
        }),
      );

      expect(found?.name, 'MyPage');
    });

    test('otherwise takes the first public widget', () {
      final found = findPublicWidget(
        detail('x/y', {
          'x/y.dart':
              'class _Private $stateless}\nclass First $stateless}\n'
              'class Second $stateless}',
        }),
      );

      expect(found?.name, 'First');
    });

    test('skips state classes, abstract widgets and non-widgets', () {
      final found = findPublicWidget(
        detail('x/y', {
          'x/y.dart':
              'class Model {}\nclass Foo extends State<Bar> {}\n'
              'abstract class Base $stateless}\nclass Real $stateless}',
        }),
      );

      expect(found?.name, 'Real');
    });

    test('looks in main.dart first for a template', () {
      final found = findPublicWidget(
        detail('templates/shop', {
          'templates/shop/a/tile.dart': 'class Tile $stateless}',
          'templates/shop/main.dart': 'class ShopApp $stateless}',
        }),
      );

      expect(found?.name, 'ShopApp');
    });

    test('returns null when there is no widget', () {
      expect(
        findPublicWidget(detail('x/y', {'x/y.dart': 'class Model {}'})),
        isNull,
      );
    });

    test('reads the constructor', () {
      String expression(String constructor) => findPublicWidget(
        detail('x/y', {'x/y.dart': 'class Y $stateless\n  $constructor\n}\n'}),
      )!.expression;

      expect(expression('const Y({super.key});'), 'const Y()');
      expect(expression('Y({super.key});'), 'Y()');
      expect(expression('const Y({super.key, this.a = 1});'), 'const Y()');
      expect(expression(''), 'Y()');
      expect(
        expression('const Y({required this.a, super.key});'),
        contains('see its constructor'),
      );
      expect(expression('const Y(this.a);'), contains('see its constructor'));
    });
  });

  test('--version matches pubspec.yaml', () async {
    final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as Map;
    final result = await runCli(['--version'], useFixture: false);

    expect(result.out.trim(), pubspec['version']);
    expect(packageVersion, pubspec['version']);
  });

  test('an unknown command is a usage error', () async {
    final result = await runCli(['frobnicate'], useFixture: false);

    expect(result.code, 64);
    expect(result.err, contains('frobnicate'));
  });
}
