import 'dart:convert';
import 'dart:io';

import 'add.dart';
import 'errors.dart';
import 'installer.dart';
import 'models.dart';
import 'public_widget.dart';
import 'registry.dart';
import 'search.dart';
import 'version.dart';

/// Protocol revisions the server can speak, newest first. Only tools are
/// implemented, and they are the same in all of them.
const _protocolVersions = [
  '2025-11-25',
  '2025-06-18',
  '2025-03-26',
  '2024-11-05',
];

const _parseError = -32700;
const _invalidRequest = -32600;
const _methodNotFound = -32601;
const _invalidParams = -32602;

const _defaultSearchLimit = 10;

/// Long enough for the burst of calls an agent makes while it works, short
/// enough that a long-lived server sees a registry update soon after it lands.
const _defaultIndexTtl = Duration(minutes: 5);

const _tools = [
  {
    'name': 'search_widgets',
    'description':
        'Search the fluttertemplates.dev library of Flutter screens by title, '
        'description, category and the Flutter widgets they use. Returns ids '
        'for get_widget and add_widget, best match first.',
    'annotations': {'readOnlyHint': true},
    'inputSchema': {
      'type': 'object',
      'properties': {
        'query': {
          'type': 'string',
          'description': 'Search words, e.g. "login form" or "NavigationBar".',
        },
        'category': {
          'type': 'string',
          'description': 'Only search this category id; see list_categories.',
        },
        'limit': {
          'type': 'integer',
          'description': 'Most results to return. Defaults to 10.',
          'minimum': 1,
        },
      },
      'required': ['query'],
    },
  },
  {
    'name': 'get_widget',
    'description':
        'Get one widget: its full Dart source files, package dependencies, '
        'license, the public widget class to use, and the command that adds '
        'it. Source copied by hand must keep the notice at licenseUrl.',
    'annotations': {'readOnlyHint': true},
    'inputSchema': {
      'type': 'object',
      'properties': {
        'id': {
          'type': 'string',
          'description': 'Widget id, e.g. "auth/signup_terms".',
        },
      },
      'required': ['id'],
    },
  },
  {
    'name': 'list_categories',
    'description': 'List the widget categories with their widget counts.',
    'annotations': {'readOnlyHint': true},
    'inputSchema': {'type': 'object', 'properties': <String, dynamic>{}},
  },
  {
    'name': 'add_widget',
    'description':
        'Copy widgets into a Flutter project, with their license notice, and '
        'run flutter pub add for any packages they need. All or nothing: an '
        'unknown id or an existing file that differs changes nothing. Returns '
        'the files written and how to use each widget.',
    'annotations': {'readOnlyHint': false, 'destructiveHint': true},
    'inputSchema': {
      'type': 'object',
      'properties': {
        'ids': {
          'type': 'array',
          'items': {'type': 'string'},
          'minItems': 1,
          'description': 'Widget ids, e.g. ["auth/signup_terms"].',
        },
        'project': {
          'type': 'string',
          'description':
              'Absolute path inside the Flutter project. Defaults to the '
              'directory the server runs in.',
        },
        'dir': {
          'type': 'string',
          'description':
              'Directory to copy into, relative to the project root. '
              'Defaults to lib/fluttertemplates.',
        },
        'force': {
          'type': 'boolean',
          'description': 'Overwrite existing files that differ.',
        },
        'dryRun': {
          'type': 'boolean',
          'description': 'Report what would happen without changing anything.',
        },
      },
      'required': ['ids'],
    },
  },
];

/// A Model Context Protocol server: JSON-RPC 2.0, one message per line.
class McpServer {
  McpServer(
    this._registry,
    this._send, {
    Duration indexTtl = _defaultIndexTtl,
    DateTime Function() now = DateTime.now,
    String? cwd,
    PubAdd pubAdd = flutterPubAdd,
  }) : _indexTtl = indexTtl,
       _now = now,
       _cwd = cwd ?? Directory.current.path,
       _pubAdd = pubAdd;

  final Registry _registry;
  final void Function(String line) _send;
  final Duration _indexTtl;
  final DateTime Function() _now;
  final String _cwd;
  final PubAdd _pubAdd;
  (RegistryIndex, DateTime)? _cachedIndex;

  /// The registry's index, fetched at most once per [_indexTtl]. Failures are
  /// not kept, so the next call tries again.
  Future<RegistryIndex> _index() async {
    final now = _now();
    if (_cachedIndex case (
      final index,
      final fetched,
    ) when now.difference(fetched) < _indexTtl) {
      return index;
    }
    final index = await _registry.index();
    _cachedIndex = (index, now);
    return index;
  }

  /// Answers [lines] one at a time until the stream ends.
  Future<void> serve(Stream<String> lines) async {
    await for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final response = await handle(line);
      if (response != null) _send(jsonEncode(response));
    }
  }

  /// Returns the response to [line], or null for a notification.
  Future<Map<String, dynamic>?> handle(String line) async {
    final Object? message;
    try {
      message = jsonDecode(line);
    } on FormatException {
      return _error(null, _parseError, 'Parse error');
    }
    if (message is! Map<String, dynamic>) {
      return _error(null, _invalidRequest, 'Expected a JSON-RPC object');
    }

    final Object? id = message['id'];
    final method = message['method'];
    final validId = id == null || id is String || id is num;
    if (message['jsonrpc'] != '2.0' || method is! String || !validId) {
      return _error(validId ? id : null, _invalidRequest, 'Invalid request');
    }

    // Requests have an id, and only requests get an answer.
    if (!message.containsKey('id')) return null;
    if (id == null) return _error(null, _invalidRequest, 'Invalid request');

    final params = message['params'] ?? <String, dynamic>{};
    if (params is! Map<String, dynamic>) {
      return _error(id, _invalidParams, 'params must be an object');
    }

    switch (method) {
      case 'initialize':
        return _result(id, _initialize(params));
      case 'ping':
        return _result(id, <String, dynamic>{});
      case 'tools/list':
        return _result(id, {'tools': _tools});
      case 'tools/call':
        return _callTool(id, params);
      default:
        return _error(id, _methodNotFound, 'Method not found: $method');
    }
  }

  Map<String, dynamic> _initialize(Map<String, dynamic> params) {
    final requested = params['protocolVersion'];
    return {
      'protocolVersion': _protocolVersions.contains(requested)
          ? requested
          : _protocolVersions.first,
      'capabilities': {'tools': <String, dynamic>{}},
      'serverInfo': {'name': 'fluttertemplates', 'version': packageVersion},
      'instructions':
          'Use search_widgets to find a Flutter screen, get_widget to read '
          'its source, and add_widget to copy it into the project. Source '
          'copied by hand must keep the notice at licenseUrl.',
    };
  }

  Future<Map<String, dynamic>> _callTool(
    Object id,
    Map<String, dynamic> params,
  ) async {
    final name = params['name'];
    final arguments = params['arguments'] ?? <String, dynamic>{};
    if (arguments is! Map<String, dynamic>) {
      return _error(id, _invalidParams, 'arguments must be an object');
    }
    final Future<Object?> Function(Map<String, dynamic>) tool;
    switch (name) {
      case 'search_widgets':
        tool = _searchWidgets;
      case 'get_widget':
        tool = _getWidget;
      case 'list_categories':
        tool = _listCategories;
      case 'add_widget':
        tool = _addWidget;
      default:
        return _error(id, _invalidParams, 'Unknown tool: $name');
    }

    // Failures of the tool itself are results, so the model can read them and
    // react; JSON-RPC errors are for protocol problems.
    try {
      final output = await tool(arguments);
      return _result(id, {
        'content': [
          {'type': 'text', 'text': jsonEncode(output)},
        ],
        'isError': false,
      });
    } on CliException catch (e) {
      return _result(id, {
        'content': [
          {'type': 'text', 'text': e.message},
        ],
        'isError': true,
      });
    }
  }

  Future<Object?> _searchWidgets(Map<String, dynamic> arguments) async {
    final query = _string(arguments, 'query');
    final category = arguments['category'];
    final limit = arguments['limit'] ?? _defaultSearchLimit;
    if (category != null && category is! String) {
      throw CliException('"category" must be a string.');
    }
    if (limit is! int || limit < 1) {
      throw CliException('"limit" must be a positive integer.');
    }

    final index = await _index();
    if (category != null && !_hasCategory(index, category as String)) {
      throw CliException(
        unknownMessage('category', category, [
          for (final known in index.categories) known.id,
        ]),
      );
    }
    final candidates = category == null
        ? index.widgets
        : index.widgets.where((widget) => widget.category == category);
    final hits = searchWidgets(candidates, query);
    return {
      'total': hits.length,
      'results': [
        for (final hit in hits.take(limit))
          {
            'id': hit.widget.id,
            'title': hit.widget.title,
            'description': hit.widget.description,
            'category': hit.widget.category,
            'url': hit.widget.url,
            'dependencies': [
              for (final dep in hit.widget.dependencies) dep.name,
            ],
          },
      ],
    };
  }

  bool _hasCategory(RegistryIndex index, String category) =>
      index.widgets.any((widget) => widget.category == category);

  Future<Object?> _getWidget(Map<String, dynamic> arguments) async {
    final id = _string(arguments, 'id');
    final index = await _index();
    final summary = findWidget(index, id);
    final detail = await _registry.widget(summary.id);
    final public = findPublicWidget(detail);
    return {
      ...summary.toJson(),
      'publicWidget': public?.name,
      'usage': public?.expression,
      'addCommand': addCommandFor(summary.id, _registry),
      'files': [
        for (final file in detail.files)
          {'path': file.path, 'content': file.content},
      ],
    };
  }

  Future<Object?> _listCategories(Map<String, dynamic> arguments) async {
    final index = await _index();
    return {
      'categories': [
        for (final category in index.categories) category.toJson(),
      ],
    };
  }

  Future<Object?> _addWidget(Map<String, dynamic> arguments) async {
    final ids = arguments['ids'];
    if (ids is! List ||
        ids.isEmpty ||
        ids.any((id) => id is! String || id.trim().isEmpty)) {
      throw CliException('"ids" must be a non-empty list of widget ids.');
    }
    final project = _optional<String>(arguments, 'project', 'a string');
    final dir = _optional<String>(arguments, 'dir', 'a string');
    final force = _optional<bool>(arguments, 'force', 'a boolean') ?? false;
    final dryRun = _optional<bool>(arguments, 'dryRun', 'a boolean') ?? false;

    final warnings = <String>[];
    final result = await addWidgets(
      registry: _registry,
      index: await _index(),
      ids: ids.cast<String>(),
      from: project ?? _cwd,
      dir: dir ?? defaultInstallDir,
      force: force,
      dryRun: dryRun,
      pubAdd: _pubAdd,
      conflictHint: 'Set force to overwrite, or dir to install somewhere else.',
      warn: warnings.add,
    );
    return {
      'project': result.project.root,
      'dryRun': dryRun,
      'files': [
        for (final file in result.plan.files)
          {'path': file.relativePath, 'action': file.action.name},
      ],
      'packages': result.plan.packages,
      'warnings': warnings,
      'usage': [
        for (final usage in usageOf(result))
          {
            'id': usage.id,
            'widget': usage.name,
            'import': usage.import,
            'path': usage.location,
            'code': usage.code,
          },
      ],
    };
  }

  T? _optional<T extends Object>(
    Map<String, dynamic> arguments,
    String key,
    String expected,
  ) {
    final value = arguments[key];
    if (value != null && value is! T) {
      throw CliException('"$key" must be $expected.');
    }
    return value as T?;
  }

  String _string(Map<String, dynamic> arguments, String key) {
    final value = arguments[key];
    if (value is! String || value.trim().isEmpty) {
      throw CliException('"$key" must be a non-empty string.');
    }
    return value;
  }

  Map<String, dynamic> _result(Object id, Map<String, dynamic> result) => {
    'jsonrpc': '2.0',
    'id': id,
    'result': result,
  };

  Map<String, dynamic> _error(Object? id, int code, String message) => {
    'jsonrpc': '2.0',
    'id': id,
    'error': {'code': code, 'message': message},
  };
}
