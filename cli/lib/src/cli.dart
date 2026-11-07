import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;

import 'add.dart';
import 'errors.dart';
import 'installer.dart';
import 'mcp.dart';
import 'models.dart';
import 'public_widget.dart';
import 'registry.dart';
import 'search.dart';
import 'version.dart';

const _usageExitCode = 64;
const _defaultSearchLimit = 20;

/// The outside world, replaceable in tests.
class CliContext {
  CliContext({
    StringSink? out,
    StringSink? err,
    Map<String, String>? environment,
    String? cwd,
    http.Client? client,
    PubAdd? pubAdd,
    Stream<String>? input,
  }) : out = out ?? stdout,
       err = err ?? stderr,
       environment = environment ?? Platform.environment,
       cwd = cwd ?? Directory.current.path,
       client = client ?? http.Client(),
       pubAdd = pubAdd ?? flutterPubAdd,
       input =
           input ??
           stdin
               .transform(const Utf8Decoder(allowMalformed: true))
               .transform(const LineSplitter());

  final StringSink out;
  final StringSink err;
  final Map<String, String> environment;
  final String cwd;
  final http.Client client;
  final PubAdd pubAdd;

  /// Lines of standard input, read by the MCP server.
  final Stream<String> input;
}

/// Runs the tool with [args] and returns its exit code.
Future<int> run(List<String> args, {CliContext? context}) async {
  final ctx = context ?? CliContext();
  final runner = _Runner(ctx);
  try {
    return await runner.run(args) ?? 0;
  } on UsageException catch (e) {
    ctx.err.writeln(e);
    return _usageExitCode;
  } on CliException catch (e) {
    ctx.err.writeln('Error: ${e.message}');
    return 1;
  } finally {
    ctx.client.close();
  }
}

class _Runner extends CommandRunner<int> {
  _Runner(CliContext ctx)
    : super(
        'fluttertemplates',
        'Find Flutter screens on fluttertemplates.dev and add them to your '
            'project.',
      ) {
    _addRegistryOption(argParser);
    argParser.addFlag(
      'version',
      negatable: false,
      help: 'Print the version of this tool.',
    );
    addCommand(_ListCommand(ctx));
    addCommand(_SearchCommand(ctx));
    addCommand(_InfoCommand(ctx));
    addCommand(_AddCommand(ctx));
    addCommand(_McpCommand(ctx));
    _ctx = ctx;
  }

  late final CliContext _ctx;

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults.flag('version')) {
      _ctx.out.writeln(packageVersion);
      return 0;
    }
    return super.runCommand(topLevelResults);
  }
}

void _addRegistryOption(ArgParser parser) {
  parser.addOption(
    'registry',
    valueHelp: 'url-or-dir',
    help:
        'Registry to read from. Falls back to \$$registryEnvVar, then '
        '$defaultRegistry.',
  );
}

abstract class _Command extends Command<int> {
  _Command(this.ctx) {
    // Also accepted after the command: `fluttertemplates list --registry x`.
    _addRegistryOption(argParser);
  }

  final CliContext ctx;

  Registry get registry {
    final candidates = [
      argResults?.option('registry'),
      globalResults?.option('registry'),
      ctx.environment[registryEnvVar],
    ];
    final location = candidates.firstWhere(
      (value) => value != null && value.isNotEmpty,
      orElse: () => defaultRegistry,
    );
    return Registry.open(location!, cwd: ctx.cwd, client: ctx.client);
  }

  List<String> get rest => argResults!.rest;
}

class _ListCommand extends _Command {
  _ListCommand(super.ctx) {
    argParser.addOption(
      'category',
      abbr: 'c',
      valueHelp: 'category',
      help: 'Only list this category.',
    );
  }

  @override
  String get name => 'list';

  @override
  String get description => 'List the available widgets.';

  @override
  String get invocation => '${runner!.executableName} list [--category <c>]';

  @override
  Future<int> run() async {
    if (rest.isNotEmpty) usageException('list takes no arguments.');
    final index = await registry.index();
    final wanted = argResults!.option('category');

    var categories = index.categories;
    if (wanted != null) {
      final needle = wanted.toLowerCase();
      categories = [
        for (final category in categories)
          if (category.id.toLowerCase() == needle ||
              category.title.toLowerCase() == needle)
            category,
      ];
      if (categories.isEmpty) {
        throw CliException(
          unknownMessage('category', wanted, [
            for (final category in index.categories) category.id,
          ]),
        );
      }
    }

    var first = true;
    for (final category in categories) {
      if (!first) ctx.out.writeln();
      first = false;
      ctx.out.writeln('${category.title} (${category.count})');
      final widgets =
          index.widgets.where((w) => w.category == category.id).toList()
            ..sort((a, b) => a.id.compareTo(b.id));
      _printTable(ctx.out, widgets);
    }
    return 0;
  }
}

void _printTable(StringSink out, List<WidgetSummary> widgets) {
  final width = widgets.fold(0, (w, widget) {
    return widget.id.length > w ? widget.id.length : w;
  });
  for (final widget in widgets) {
    out.writeln('  ${widget.id.padRight(width)}  ${widget.title}');
  }
}

class _SearchCommand extends _Command {
  _SearchCommand(super.ctx) {
    argParser.addOption(
      'limit',
      abbr: 'n',
      defaultsTo: '$_defaultSearchLimit',
      help: 'Most results to show.',
    );
  }

  @override
  String get name => 'search';

  @override
  String get description =>
      'Search widgets by title, description, category and Flutter widgets.';

  @override
  String get invocation => '${runner!.executableName} search <query>';

  @override
  Future<int> run() async {
    if (rest.isEmpty) usageException('Tell me what to search for.');
    final limit = int.tryParse(argResults!.option('limit')!);
    if (limit == null || limit < 1) {
      usageException('--limit must be a positive number.');
    }
    final query = rest.join(' ');
    final index = await registry.index();
    final hits = searchWidgets(index.widgets, query);
    if (hits.isEmpty) {
      ctx.out.writeln('No widgets match "$query".');
      return 0;
    }
    final shown = hits.take(limit).toList();
    for (final hit in shown) {
      ctx.out.writeln('${hit.widget.id}  ${hit.widget.title}');
      ctx.out.writeln('  ${hit.widget.description}');
    }
    if (hits.length > shown.length) {
      ctx.out.writeln(
        '\nShowing ${shown.length} of ${hits.length}. '
        'Use --limit to see more.',
      );
    }
    return 0;
  }
}

class _InfoCommand extends _Command {
  @override
  String get name => 'info';

  _InfoCommand(super.ctx);

  @override
  String get description => 'Show the details of a widget.';

  @override
  String get invocation => '${runner!.executableName} info <id>';

  @override
  Future<int> run() async {
    if (rest.length != 1) usageException('info takes exactly one widget id.');
    final source = registry;
    final summary = findWidget(await source.index(), rest.single);
    final detail = await source.widget(summary.id);
    final public = findPublicWidget(detail);
    final out = ctx.out;

    out.writeln(summary.title);
    if (summary.description.isNotEmpty) out.writeln(summary.description);
    out.writeln();
    out.writeln('Id:       ${summary.id}');
    out.writeln('Category: ${summary.categoryTitle} (${summary.category})');
    if (summary.url.isNotEmpty) out.writeln('Preview:  ${summary.url}');
    out.writeln('Lines:    ${summary.loc}');
    if (public != null) out.writeln('Widget:   ${public.name}');
    if (summary.flutterWidgets.isNotEmpty) {
      out.writeln('Uses:     ${summary.flutterWidgets.join(', ')}');
    }
    out.writeln(
      'Packages: ${summary.dependencies.isEmpty ? 'none' : [for (final dep in summary.dependencies) '${dep.name} ${dep.version}'].join(', ')}',
    );
    final license = summary.license;
    final licenseUrl = summary.licenseUrl;
    out.writeln(
      'License:  ${license ?? 'not declared by this registry'}'
      '${license != null && licenseUrl != null ? ' ($licenseUrl)' : ''}',
    );
    out.writeln('Files:');
    for (final file in detail.files) {
      out.writeln('  ${file.path}');
    }
    out.writeln();
    out.writeln('Add it: ${addCommandFor(summary.id, source)}');
    return 0;
  }
}

class _AddCommand extends _Command {
  _AddCommand(super.ctx) {
    argParser
      ..addOption(
        'dir',
        defaultsTo: defaultInstallDir,
        help: 'Directory to copy into, relative to the project root.',
      )
      ..addFlag(
        'force',
        abbr: 'f',
        negatable: false,
        help: 'Overwrite files that already exist.',
      )
      ..addFlag(
        'dry-run',
        abbr: 'n',
        negatable: false,
        help: 'Show what would happen without changing anything.',
      );
  }

  @override
  String get name => 'add';

  @override
  String get description => 'Copy widgets into the current Flutter project.';

  @override
  String get invocation => '${runner!.executableName} add <id>... [options]';

  @override
  Future<int> run() async {
    if (rest.isEmpty) usageException('Name at least one widget id to add.');
    final dryRun = argResults!.flag('dry-run');

    final source = registry;
    final result = await addWidgets(
      registry: source,
      index: await source.index(),
      ids: rest,
      from: ctx.cwd,
      dir: argResults!.option('dir')!,
      force: argResults!.flag('force'),
      dryRun: dryRun,
      pubAdd: ctx.pubAdd,
      conflictHint:
          'Use --force to overwrite, or --dir to install somewhere else.',
      warn: (warning) => ctx.err.writeln('Warning: $warning'),
    );

    if (dryRun) ctx.out.writeln('Dry run: nothing was changed.\n');
    _report(result.plan, dryRun);
    _printUsage(result);
    return 0;
  }

  void _report(InstallPlan plan, bool dryRun) {
    final labels = {
      FileAction.create: dryRun ? 'would create' : 'created',
      FileAction.overwrite: dryRun ? 'would overwrite' : 'overwrote',
      FileAction.unchanged: 'unchanged',
    };
    for (final file in plan.files) {
      ctx.out.writeln('${labels[file.action]}: ${file.relativePath}');
    }
    if (plan.packages.isNotEmpty) {
      final verb = dryRun ? 'would run' : 'ran';
      ctx.out.writeln('$verb: flutter pub add ${plan.packages.join(' ')}');
    }
  }

  void _printUsage(AddResult result) {
    for (final usage in usageOf(result)) {
      ctx.out.writeln();
      if (usage.name == null) {
        ctx.out.writeln('${usage.id} declares no public widget class.');
        continue;
      }
      ctx.out.writeln('Use ${usage.name} from ${usage.id}:');
      ctx.out.writeln(
        '  ${usage.import ?? '// Import ${usage.location} with a relative path.'}',
      );
      ctx.out.writeln();
      ctx.out.writeln('  ${usage.code}');
    }
  }
}

class _McpCommand extends _Command {
  _McpCommand(super.ctx);

  @override
  String get name => 'mcp';

  @override
  String get description =>
      'Run a Model Context Protocol server on standard input and output.';

  @override
  Future<int> run() async {
    if (rest.isNotEmpty) usageException('mcp takes no arguments.');
    final server = McpServer(
      registry,
      ctx.out.writeln,
      cwd: ctx.cwd,
      pubAdd: ctx.pubAdd,
    );
    await server.serve(ctx.input);
    return 0;
  }
}
