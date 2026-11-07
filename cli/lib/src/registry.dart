import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'errors.dart';
import 'models.dart';
import 'suggest.dart';
import 'version.dart';

const defaultRegistry = 'https://fluttertemplates.dev/r';
const registryEnvVar = 'FLUTTERTEMPLATES_REGISTRY';

/// The newest `index.json` format this version of the tool understands.
const supportedRegistryVersion = 1;

const _requestTimeout = Duration(seconds: 30);

/// Read access to a registry, hosted or in a local directory.
abstract class Registry {
  Registry();

  /// Opens [location], a URL or a directory path. Relative paths are resolved
  /// against [cwd].
  factory Registry.open(
    String location, {
    required String cwd,
    required http.Client client,
  }) {
    final uri = Uri.tryParse(location);
    final scheme = uri?.scheme ?? '';
    if (scheme == 'http' || scheme == 'https') {
      return _HttpRegistry(location.replaceFirst(RegExp(r'/+$'), ''), client);
    }
    if (scheme == 'file') return _DirectoryRegistry(uri!.toFilePath());
    // A single letter is a Windows drive, not a scheme.
    if (scheme.length > 1) {
      throw CliException(
        'Unsupported registry "$location": use an http(s) URL or a directory.',
      );
    }
    return _DirectoryRegistry(p.normalize(p.join(cwd, location)));
  }

  /// Where this registry lives, for messages.
  String get location;

  /// Returns the text of [file], a path relative to the registry root.
  Future<String> _read(String file);

  Future<RegistryIndex> index() async {
    final json = await _readJson('index.json');
    try {
      final map = json as Map<String, dynamic>;
      final version = map['version'] as int? ?? 1;
      if (version > supportedRegistryVersion) {
        throw CliException(
          'Registry at $location uses format $version, but this version of '
          'fluttertemplates only reads format $supportedRegistryVersion. '
          'Update with: dart pub global activate fluttertemplates_dev',
        );
      }
      return RegistryIndex(
        version: version,
        widgets: [
          // An entry without its own license falls under the registry's.
          for (final entry in map['widgets'] as List<dynamic>)
            WidgetSummary.fromJson({
              'license': map['license'],
              'licenseUrl': map['licenseUrl'],
              ...entry as Map<String, dynamic>,
            }),
        ],
      );
    } on TypeError {
      throw CliException('Registry at $location has a malformed index.json.');
    }
  }

  /// Fetches the widget [id], which must come from [index].
  Future<WidgetDetail> widget(String id) async {
    if (id.split('/').any((part) => part.isEmpty || part.startsWith('.'))) {
      throw CliException('Registry at $location lists an invalid id: "$id".');
    }
    final json = await _readJson('$id.json');
    try {
      return WidgetDetail.fromJson(json as Map<String, dynamic>);
    } on TypeError {
      throw CliException('Registry at $location has a malformed $id.json.');
    }
  }

  /// Returns the text of the registry's LICENSE file. It always comes from
  /// here rather than `licenseUrl`, so that a local registry works offline.
  Future<String> licenseText() async {
    final text = await _read('LICENSE');
    if (text.trim().isEmpty) {
      throw CliException('Registry at $location has an empty LICENSE file.');
    }
    return text;
  }

  Future<Object?> _readJson(String file) async {
    final text = await _read(file);
    try {
      return jsonDecode(text);
    } on FormatException {
      throw CliException(
        '$file from registry $location is not valid JSON. '
        'Is this really a fluttertemplates registry?',
      );
    }
  }
}

class _DirectoryRegistry extends Registry {
  _DirectoryRegistry(this.location);

  @override
  final String location;

  @override
  Future<String> _read(String file) async {
    if (!Directory(location).existsSync()) {
      throw CliException('Registry directory not found: $location');
    }
    final target = File(p.joinAll([location, ...file.split('/')]));
    try {
      return await target.readAsString();
    } on PathNotFoundException {
      throw CliException('Registry $location has no $file.');
    } on FileSystemException catch (e) {
      throw CliException('Could not read ${target.path}: ${e.message}');
    } on FormatException {
      throw CliException('${target.path} is not valid UTF-8.');
    }
  }
}

class _HttpRegistry extends Registry {
  _HttpRegistry(this.location, this._client);

  @override
  final String location;
  final http.Client _client;

  @override
  Future<String> _read(String file) async {
    final url = '$location/$file';
    final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(url),
            headers: {'user-agent': 'fluttertemplates-cli/$packageVersion'},
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw _unreachable(url, 'timed out after ${_requestTimeout.inSeconds}s');
    } on http.ClientException catch (e) {
      throw _unreachable(url, e.message);
    } on SocketException catch (e) {
      throw _unreachable(url, e.message);
    } on TlsException catch (e) {
      throw _unreachable(url, e.message);
    } on FormatException {
      throw CliException('Invalid registry URL: $url');
    }
    if (response.statusCode != 200) {
      throw CliException(
        'Registry request failed: HTTP ${response.statusCode} '
        'for $url',
      );
    }
    try {
      // Not `response.body`: without a charset header that decodes as Latin-1.
      return utf8.decode(response.bodyBytes);
    } on FormatException {
      throw CliException('Response from $url is not valid UTF-8.');
    }
  }

  CliException _unreachable(String url, String reason) => CliException(
    'Could not reach the registry at $url ($reason).\n'
    'Check your connection, or point --registry at a local directory.',
  );
}

/// The command that adds [id] from [registry]. Ids and locations can come from
/// a third party and this ends up in a shell, so both are quoted when needed.
String addCommandFor(String id, Registry registry) {
  final command = 'fluttertemplates add ${_shellQuote(id)}';
  if (registry.location == defaultRegistry) return command;
  return '$command --registry ${_shellQuote(registry.location)}';
}

final _shellSafe = RegExp(r'^[\w./:@%+=,-]+$');

String _shellQuote(String value) {
  if (_shellSafe.hasMatch(value)) return value;
  if (Platform.isWindows) return '"${value.replaceAll('"', r'\"')}"';
  return "'${value.replaceAll("'", r"'\''")}'";
}

/// Finds [id] in [index], or fails with the closest ids as suggestions.
WidgetSummary findWidget(RegistryIndex index, String id) {
  for (final widget in index.widgets) {
    if (widget.id == id) return widget;
  }
  throw CliException(
    unknownMessage('widget', id, [
      for (final widget in index.widgets) widget.id,
    ]),
  );
}

String unknownMessage(String kind, String value, Iterable<String> known) {
  final close = closeMatches(value, known);
  final hint = close.isEmpty
      ? ''
      : '\nDid you mean:\n${close.map((match) => '  $match').join('\n')}';
  return 'Unknown $kind "$value".$hint';
}
