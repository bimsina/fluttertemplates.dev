import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support.dart';

void main() {
  const index =
      '{"version":1,"widgets":[{"id":"a/b","title":"Ünï","category":"a"}]}';

  group('choosing a registry', () {
    final seen = <Uri>[];
    http.Client recorder() => MockClient((request) async {
      seen.add(request.url);
      return http.Response(index, 200);
    });

    setUp(seen.clear);

    test('defaults to the hosted registry', () async {
      await runCli(['list'], useFixture: false, client: recorder());

      expect(
        seen.single.toString(),
        'https://fluttertemplates.dev/r/index.json',
      );
    });

    test('reads the environment', () async {
      await runCli(
        ['list'],
        useFixture: false,
        client: recorder(),
        environment: {'FLUTTERTEMPLATES_REGISTRY': 'https://env.test/r/'},
      );

      expect(seen.single.toString(), 'https://env.test/r/index.json');
    });

    test('--registry beats the environment', () async {
      await runCli(
        ['--registry', 'https://flag.test/r', 'list'],
        useFixture: false,
        client: recorder(),
        environment: {'FLUTTERTEMPLATES_REGISTRY': 'https://env.test/r'},
      );

      expect(seen.single.host, 'flag.test');
    });

    test('--registry also works after the command', () async {
      final result = await runCli([
        'list',
        '--registry',
        fixtureRegistry,
      ], useFixture: false);

      expect(result.code, 0, reason: result.err);
      expect(result.out, contains('auth/login_screen'));
    });

    test('accepts a relative directory', () async {
      final result = await runCli([
        '--registry',
        'test/fixtures/registry',
        'list',
      ], useFixture: false);

      expect(result.code, 0, reason: result.err);
    });

    test('accepts a file: URL', () async {
      final result = await runCli([
        '--registry',
        Uri.directory(fixtureRegistry).toString(),
        'list',
      ], useFixture: false);

      expect(result.code, 0, reason: result.err);
    });

    test('rejects other schemes', () async {
      final result = await runCli([
        '--registry',
        'ftp://example.com/r',
        'list',
      ], useFixture: false);

      expect(result.code, 1);
      expect(result.err, contains('Unsupported registry'));
    });
  });

  test('fetches widgets over HTTP using their full id', () async {
    final project = flutterProject();
    final detail = File(
      p.join(fixtureRegistry, 'navigation/bottom_navigation/fancy_bar.json'),
    ).readAsStringSync();
    final indexJson = File(
      p.join(fixtureRegistry, 'index.json'),
    ).readAsStringSync();
    final client = MockClient((request) async {
      // No charset on purpose: the body must still be read as UTF-8.
      final headers = {'content-type': 'application/json'};
      final body = switch (request.url.path) {
        '/r/index.json' => indexJson,
        '/r/navigation/bottom_navigation/fancy_bar.json' => detail,
        '/r/LICENSE' => 'the notice of this registry\n',
        _ => null,
      };
      return body == null
          ? http.Response('', 404)
          : http.Response.bytes(utf8.encode(body), 200, headers: headers);
    });

    final result = await runCli(
      ['add', 'navigation/bottom_navigation/fancy_bar'],
      useFixture: false,
      cwd: project.path,
      client: client,
      environment: {'FLUTTERTEMPLATES_REGISTRY': 'https://example.test/r'},
    );

    expect(result.code, 0, reason: result.err);
    expect(
      File(
        p.join(project.path, 'lib', 'fluttertemplates', 'LICENSE'),
      ).readAsStringSync(),
      'the notice of this registry\n',
    );
    final file = File(
      p.join(
        project.path,
        'lib/fluttertemplates/navigation/bottom_nav/fancy_bar.dart',
      ),
    );
    expect(file.readAsStringSync(), contains('Café'));
  });

  group('failures are readable and exit non-zero', () {
    void expectFailure(Result result, Matcher message) {
      expect(result.code, 1);
      expect(result.err, startsWith('Error: '));
      expect(result.err, message);
      expect(result.err, isNot(contains('#0')), reason: 'no stack traces');
    }

    test('nothing listening on the port', () async {
      // Bind and release a port, so that it is known to be closed.
      final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = socket.port;
      await socket.close();

      final result = await runCli([
        '--registry',
        'http://127.0.0.1:$port/r',
        'list',
      ], useFixture: false);

      expectFailure(result, contains('Could not reach the registry'));
    });

    test('client errors', () async {
      final result = await runCli(
        ['--registry', 'https://x.test/r', 'list'],
        useFixture: false,
        client: MockClient((_) => throw http.ClientException('no route')),
      );

      expectFailure(result, contains('no route'));
    });

    test('HTTP errors', () async {
      final result = await runCli(
        ['--registry', 'https://x.test/r', 'list'],
        useFixture: false,
        client: MockClient((_) async => http.Response('nope', 503)),
      );

      expectFailure(result, contains('HTTP 503'));
    });

    test('a page that is not JSON', () async {
      final result = await runCli(
        ['--registry', 'https://x.test/r', 'list'],
        useFixture: false,
        client: MockClient((_) async => http.Response('<html>', 200)),
      );

      expectFailure(result, contains('not valid JSON'));
    });

    test('JSON of the wrong shape', () async {
      final result = await runCli(
        ['--registry', 'https://x.test/r', 'list'],
        useFixture: false,
        client: MockClient((_) async => http.Response('{"widgets":3}', 200)),
      );

      expectFailure(result, contains('malformed index.json'));
    });

    test('a newer registry format', () async {
      final result = await runCli(
        ['--registry', 'https://x.test/r', 'list'],
        useFixture: false,
        client: MockClient(
          (_) async => http.Response('{"version":99,"widgets":[]}', 200),
        ),
      );

      expectFailure(result, contains('format 99'));
    });

    test('a missing directory', () async {
      final result = await runCli([
        '--registry',
        p.join(tempDir().path, 'nope'),
        'list',
      ], useFixture: false);

      expectFailure(result, contains('directory not found'));
    });

    test('a directory that is not a registry', () async {
      final result = await runCli([
        '--registry',
        tempDir().path,
        'list',
      ], useFixture: false);

      expectFailure(result, contains('no index.json'));
    });

    test('a listed widget whose file is missing', () async {
      final dir = tempDir();
      File(p.join(dir.path, 'index.json')).writeAsStringSync(index);
      final result = await runCli([
        '--registry',
        dir.path,
        'info',
        'a/b',
      ], useFixture: false);

      expectFailure(result, contains('no a/b.json'));
    });

    test('an id trying to leave the registry', () async {
      final dir = tempDir();
      File(
        p.join(dir.path, 'index.json'),
      ).writeAsStringSync('{"version":1,"widgets":[{"id":"../secret"}]}');
      final result = await runCli([
        '--registry',
        dir.path,
        'info',
        '../secret',
      ], useFixture: false);

      expectFailure(result, contains('invalid id'));
    });
  });
}
