import 'dart:convert';
import 'dart:io';

import 'package:fluttertemplates_dev/src/mcp.dart';
import 'package:fluttertemplates_dev/src/registry.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support.dart';

/// Serves the fixture registry over a fake network.
http.Client fixtureClient({void Function(http.Request)? onRequest}) =>
    MockClient((request) async {
      onRequest?.call(request);
      final file = File(
        p.joinAll([fixtureRegistry, ...request.url.pathSegments.skip(1)]),
      );
      if (!file.existsSync()) return http.Response('', 404);
      return http.Response.bytes(file.readAsBytesSync(), 200);
    });

void main() {
  /// Feeds [lines] to `fluttertemplates mcp` and returns the decoded replies.
  Future<List<Map<String, dynamic>>> talk(
    List<Object> lines, {
    String? cwd,
    FakePubAdd? pubAdd,
  }) async {
    final result = await runCli(
      ['mcp'],
      cwd: cwd,
      pubAdd: pubAdd,
      input: Stream.fromIterable([
        for (final line in lines) line is String ? line : jsonEncode(line),
      ]),
    );
    expect(result.code, 0, reason: result.err);
    expect(result.err, isEmpty);
    return [
      for (final line in const LineSplitter().convert(result.out))
        jsonDecode(line) as Map<String, dynamic>,
    ];
  }

  Map<String, dynamic> call(String tool, [Map<String, Object>? arguments]) => {
    'jsonrpc': '2.0',
    'id': 1,
    'method': 'tools/call',
    'params': {'name': tool, 'arguments': ?arguments},
  };

  Future<Map<String, dynamic>> callResult(
    String tool, [
    Map<String, Object>? arguments,
    String? cwd,
    FakePubAdd? pubAdd,
  ]) async {
    final replies = await talk(
      [call(tool, arguments)],
      cwd: cwd,
      pubAdd: pubAdd,
    );
    return replies.single['result'] as Map<String, dynamic>;
  }

  Object? decodedText(Map<String, dynamic> result) {
    final content = result['content'] as List<dynamic>;
    return jsonDecode((content.single as Map)['text'] as String);
  }

  test('runs the handshake', () async {
    final replies = await talk([
      {
        'jsonrpc': '2.0',
        'id': 'first',
        'method': 'initialize',
        'params': {
          'protocolVersion': '2025-06-18',
          'capabilities': <String, Object>{},
          'clientInfo': {'name': 'test', 'version': '1'},
        },
      },
      {'jsonrpc': '2.0', 'method': 'notifications/initialized'},
      {'jsonrpc': '2.0', 'id': 2, 'method': 'tools/list'},
      {'jsonrpc': '2.0', 'id': 3, 'method': 'ping'},
    ]);

    expect(replies, hasLength(3), reason: 'notifications get no reply');
    final initialize = replies[0];
    expect(initialize['id'], 'first');
    expect(initialize['jsonrpc'], '2.0');
    final result = initialize['result'] as Map;
    expect(result['protocolVersion'], '2025-06-18');
    expect(result['capabilities'], contains('tools'));
    expect((result['serverInfo'] as Map)['name'], 'fluttertemplates');

    final tools = (replies[1]['result'] as Map)['tools'] as List;
    expect(
      [for (final tool in tools.cast<Map<String, dynamic>>()) tool['name']],
      ['search_widgets', 'get_widget', 'list_categories', 'add_widget'],
    );
    for (final tool in tools.cast<Map<String, dynamic>>()) {
      expect((tool['inputSchema'] as Map)['type'], 'object');
      expect(tool['description'], isNotEmpty);
    }
    expect(replies[2]['result'], isEmpty);
  });

  test('offers its own version for an unknown protocol revision', () async {
    final replies = await talk([
      {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
        'params': {'protocolVersion': '1999-01-01'},
      },
    ]);

    expect((replies.single['result'] as Map)['protocolVersion'], '2025-11-25');
  });

  group('search_widgets', () {
    test('returns ranked results', () async {
      final result = await callResult('search_widgets', {'query': 'login'});

      expect(result['isError'], false);
      final output = decodedText(result) as Map;
      final results = output['results'] as List;
      expect((results.first as Map)['id'], 'auth/login_screen');
      expect(output['total'], greaterThan(1));
    });

    test('honours limit and category', () async {
      final result = await callResult('search_widgets', {
        'query': 'flutter',
        'category': 'auth',
        'limit': 1,
      });

      final output = decodedText(result) as Map;
      expect(output['total'], 2);
      expect(output['results'], hasLength(1));
    });

    test('reports an unknown category as a tool error', () async {
      final result = await callResult('search_widgets', {
        'query': 'x',
        'category': 'pricin',
      });

      expect(result['isError'], true);
      expect(jsonEncode(result['content']), contains('pricing'));
    });

    test('reports bad arguments as a tool error', () async {
      final result = await callResult('search_widgets');

      expect(result['isError'], true);
      expect(jsonEncode(result['content']), contains('query'));
    });
  });

  group('get_widget', () {
    test('returns the sources and how to use them', () async {
      final result = await callResult('get_widget', {
        'id': 'navigation/bottom_navigation/fancy_bar',
      });

      final output = decodedText(result) as Map;
      expect(output['publicWidget'], 'FancyBar');
      expect(output['usage'], 'FancyBar()');
      expect(
        output['addCommand'],
        'fluttertemplates add navigation/bottom_navigation/fancy_bar '
        '--registry $fixtureRegistry',
      );
      expect(output['license'], 'MIT');
      expect(output['licenseUrl'], endsWith('/r/LICENSE'));
      final file = (output['files'] as List).single as Map;
      expect(file['path'], 'navigation/bottom_nav/fancy_bar.dart');
      expect(file['content'], contains('Café'));
    });

    group('addCommand', () {
      Future<String> addCommand(
        List<String> args, {
        Map<String, String> environment = const {},
      }) async {
        final result = await runCli(
          [...args, 'mcp'],
          environment: environment,
          useFixture: false,
          client: fixtureClient(),
          input: Stream.value(
            jsonEncode(call('get_widget', {'id': 'auth/login_screen'})),
          ),
        );
        final reply = jsonDecode(result.out) as Map<String, dynamic>;
        final output = decodedText(reply['result'] as Map<String, dynamic>);
        return (output as Map)['addCommand'] as String;
      }

      test('stays short for the default registry', () async {
        expect(await addCommand([]), 'fluttertemplates add auth/login_screen');
        expect(
          await addCommand(['--registry', '$defaultRegistry/']),
          'fluttertemplates add auth/login_screen',
        );
      });

      test('names a registry given by flag', () async {
        expect(
          await addCommand(['--registry', 'https://x.test/r']),
          'fluttertemplates add auth/login_screen --registry https://x.test/r',
        );
      });

      test('names a registry given by the environment', () async {
        expect(
          await addCommand(
            [],
            environment: {registryEnvVar: 'https://x.test/r'},
          ),
          endsWith('--registry https://x.test/r'),
        );
      });

      test('quotes a location with spaces', () async {
        final dir = Directory(p.join(tempDir().path, "my 'registry'"));
        Process.runSync('cp', ['-R', fixtureRegistry, dir.path]);
        expect(
          await addCommand(['--registry', dir.path]),
          endsWith("--registry '${dir.path.replaceAll("'", r"'\''")}'"),
        );
      }, testOn: '!windows');
    });

    test('suggests close ids for an unknown one', () async {
      final result = await callResult('get_widget', {'id': 'auth/login_scren'});

      expect(result['isError'], true);
      expect(jsonEncode(result['content']), contains('auth/login_screen'));
    });
  });

  group('add_widget', () {
    final id = 'auth/signup_terms';
    late Directory project;
    File target() => File(
      p.join(project.path, 'lib/fluttertemplates/auth/signup_terms.dart'),
    );

    setUp(() => project = flutterProject());

    test('copies the files and says how to use them', () async {
      final result = await callResult('add_widget', {
        'ids': [id],
      }, project.path);
      expect(result['isError'], isFalse);
      final output = decodedText(result) as Map<String, dynamic>;
      expect(target().existsSync(), isTrue);
      expect(
        File(p.join(project.path, 'lib/fluttertemplates/LICENSE')).existsSync(),
        isTrue,
      );
      expect(output['project'], project.path);
      expect(output['files'], contains(containsPair('action', 'create')));
      final usage = (output['usage'] as List).single as Map<String, dynamic>;
      expect(usage['import'], contains('package:demo_app/'));
      expect(usage['code'], contains('home:'));
    });

    test('project overrides the working directory', () async {
      await callResult('add_widget', {
        'ids': [id],
        'project': project.path,
      }, tempDir().path);
      expect(target().existsSync(), isTrue);
    });

    test('dryRun changes nothing', () async {
      final before = treeOf(project);
      final result = await callResult('add_widget', {
        'ids': [id],
        'dryRun': true,
      }, project.path);
      expect(result['isError'], isFalse);
      expect((decodedText(result) as Map)['dryRun'], isTrue);
      expect(treeOf(project), before);
    });

    test('installs packages', () async {
      final pubAdd = FakePubAdd();
      final result = await callResult(
        'add_widget',
        {
          'ids': ['navigation/bottom_navigation/fancy_bar'],
        },
        project.path,
        pubAdd,
      );
      expect(result['isError'], isFalse);
      expect(pubAdd.calls, hasLength(1));
      expect((decodedText(result) as Map)['packages'], pubAdd.calls.single);
    });

    test('a conflict is a tool error until force is set', () async {
      target()
        ..createSync(recursive: true)
        ..writeAsStringSync('mine');
      final refused = await callResult('add_widget', {
        'ids': [id],
      }, project.path);
      expect(refused['isError'], isTrue);
      expect(jsonEncode(refused['content']), contains('Set force'));
      expect(target().readAsStringSync(), 'mine');

      final forced = await callResult('add_widget', {
        'ids': [id],
        'force': true,
      }, project.path);
      expect(forced['isError'], isFalse);
      expect(target().readAsStringSync(), isNot('mine'));
    });

    test('outside a Flutter project is a tool error', () async {
      final result = await callResult('add_widget', {
        'ids': [id],
      }, tempDir().path);
      expect(result['isError'], isTrue);
      expect(jsonEncode(result['content']), contains('pubspec.yaml'));
    });

    test('rejects a dir outside the project', () async {
      final result = await callResult('add_widget', {
        'ids': [id],
        'dir': '../elsewhere',
      }, project.path);
      expect(result['isError'], isTrue);
    });

    test('reports bad arguments as a tool error', () async {
      for (final arguments in <Map<String, Object>>[
        {},
        {'ids': <String>[]},
        {'ids': 'auth/signup_terms'},
        {
          'ids': [id],
          'force': 'yes',
        },
        {
          'ids': [id],
          'project': 3,
        },
      ]) {
        final result = await callResult('add_widget', arguments, project.path);
        expect(result['isError'], isTrue, reason: '$arguments');
      }
    });

    test('an unknown id changes nothing', () async {
      final before = treeOf(project);
      final result = await callResult('add_widget', {
        'ids': [id, 'auth/nope'],
      }, project.path);
      expect(result['isError'], isTrue);
      expect(treeOf(project), before);
    });
  });

  test('list_categories counts widgets', () async {
    final result = await callResult('list_categories');

    final categories = (decodedText(result) as Map)['categories'] as List;
    expect(
      categories,
      contains(equals({'id': 'auth', 'title': 'Authentication', 'count': 2})),
    );
  });

  test('a registry failure is a tool error, and the server lives on', () async {
    final out = await runCli(
      ['--registry', 'https://x.test/r', 'mcp'],
      useFixture: false,
      client: MockClient((_) => throw const SocketException('down')),
      input: Stream.fromIterable([
        jsonEncode(call('list_categories')),
        jsonEncode({'jsonrpc': '2.0', 'id': 2, 'method': 'ping'}),
      ]),
    );

    final replies = const LineSplitter().convert(out.out);
    expect(replies, hasLength(2));
    final first = jsonDecode(replies.first) as Map;
    expect((first['result'] as Map)['isError'], true);
  });

  group('index cache', () {
    late int fetches;
    late DateTime now;
    late bool down;
    late McpServer server;

    Future<Map<String, dynamic>> ask(
      String tool, [
      Map<String, Object>? args,
    ]) async {
      final reply = await server.handle(jsonEncode(call(tool, args)));
      return reply!['result'] as Map<String, dynamic>;
    }

    setUp(() {
      fetches = 0;
      now = DateTime(2026);
      down = false;
      final client = fixtureClient(
        onRequest: (request) {
          if (request.url.path.endsWith('/index.json')) fetches++;
          if (down) throw const SocketException('down');
        },
      );
      addTearDown(client.close);
      server = McpServer(
        Registry.open('https://x.test/r', cwd: '.', client: client),
        (_) {},
        indexTtl: const Duration(minutes: 5),
        now: () => now,
      );
    });

    test('tool calls share one fetch', () async {
      await ask('list_categories');
      await ask('search_widgets', {'query': 'login'});
      await ask('get_widget', {'id': 'auth/login_screen'});

      expect(fetches, 1);
    });

    test('expires', () async {
      await ask('list_categories');
      now = now.add(const Duration(minutes: 4, seconds: 59));
      await ask('list_categories');
      expect(fetches, 1);

      now = now.add(const Duration(seconds: 1));
      await ask('list_categories');
      expect(fetches, 2);
    });

    test('does not keep a failure', () async {
      down = true;
      expect((await ask('list_categories'))['isError'], true);

      down = false;
      expect((await ask('list_categories'))['isError'], false);
      expect(fetches, 2);
    });
  });

  group('protocol errors', () {
    int? code(Map<String, dynamic> reply) =>
        (reply['error'] as Map?)?['code'] as int?;

    test('bad JSON', () async {
      final reply = (await talk(['{nope'])).single;

      expect(code(reply), -32700);
      expect(reply['id'], isNull);
    });

    test('not an object', () async {
      expect(code((await talk(['[1,2]'])).single), -32600);
    });

    test('wrong jsonrpc version', () async {
      final replies = await talk([
        {'jsonrpc': '1.0', 'id': 1, 'method': 'ping'},
      ]);
      expect(code(replies.single), -32600);
    });

    test('unknown method', () async {
      final replies = await talk([
        {'jsonrpc': '2.0', 'id': 7, 'method': 'resources/list'},
      ]);
      expect(code(replies.single), -32601);
      expect(replies.single['id'], 7);
    });

    test('unknown tool', () async {
      final replies = await talk([call('delete_everything')]);
      expect(code(replies.single), -32602);
    });

    test('blank lines and unknown notifications are ignored', () async {
      final replies = await talk([
        '',
        '   ',
        {'jsonrpc': '2.0', 'method': 'notifications/cancelled'},
      ]);
      expect(replies, isEmpty);
    });

    test('the server survives all of the above', () async {
      final replies = await talk([
        '{nope',
        {'jsonrpc': '2.0', 'id': 1, 'method': 'ping'},
      ]);
      expect(replies.last['result'], isEmpty);
    });
  });
}
