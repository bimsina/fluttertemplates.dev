import 'package:path/path.dart' as p;

import 'errors.dart';
import 'installer.dart';
import 'models.dart';
import 'project.dart';
import 'public_widget.dart';
import 'registry.dart';

final defaultInstallDir = p.posix.join('lib', 'fluttertemplates');

/// What an `add` did, or would do on a dry run.
class AddResult {
  const AddResult({
    required this.project,
    required this.installDir,
    required this.plan,
    required this.widgets,
  });

  final FlutterProject project;
  final String installDir;
  final InstallPlan plan;
  final List<WidgetDetail> widgets;
}

/// How to use one added widget.
class WidgetUsage {
  const WidgetUsage({
    required this.id,
    this.name,
    this.import,
    this.location,
    this.code,
  });

  final String id;

  /// The public class, or null if the widget declares none.
  final String? name;

  /// A package import, or null when the file sits outside `lib`.
  final String? import;

  /// Where the file is, relative to the project root.
  final String? location;

  /// The line that shows the widget.
  final String? code;
}

/// Copies [ids] into the Flutter project around [from].
///
/// Everything is resolved up front, so that one bad id or conflict leaves the
/// project untouched rather than half installed. [conflictHint] follows the
/// conflict message, and names the way out in the caller's own terms.
Future<AddResult> addWidgets({
  required Registry registry,
  required RegistryIndex index,
  required Iterable<String> ids,
  required String from,
  required String dir,
  required bool force,
  required bool dryRun,
  required PubAdd pubAdd,
  required String conflictHint,
  required void Function(String warning) warn,
}) async {
  final project = FlutterProject.find(from);
  final installDir = resolveInstallDir(project, dir);

  final summaries = [for (final id in ids.toSet()) findWidget(index, id)];
  final widgets = await Future.wait([
    for (final summary in summaries) registry.widget(summary.id),
  ]);
  final licenseText = await _licenseText(registry, summaries, widgets);
  final plan = planInstall(
    project: project,
    installDir: installDir,
    widgets: widgets,
    force: force,
    licenseText: licenseText,
  );

  plan.warnings.forEach(warn);
  if (licenseText == null) {
    warn(
      'this registry declares no license, so no $licenseFileName file was '
      'planned. Check the terms of what you copy.',
    );
  }

  if (plan.conflicts.isNotEmpty) {
    throw CliException(
      [
        'These files already exist with different content:',
        for (final file in plan.conflicts) '  ${file.relativePath}',
        'Nothing was changed. $conflictHint',
      ].join('\n'),
    );
  }

  if (!dryRun) (await applyInstall(plan, project, pubAdd)).forEach(warn);

  return AddResult(
    project: project,
    installDir: installDir,
    plan: plan,
    widgets: widgets,
  );
}

/// The notice that has to travel with [widgets], or null if the registry
/// declares no license. A declared license that cannot be fetched stops the
/// install: copying the code without its notice would break the license.
Future<String?> _licenseText(
  Registry source,
  List<WidgetSummary> summaries,
  List<WidgetDetail> widgets,
) async {
  final declared = [
    ...summaries,
    for (final widget in widgets) widget.summary,
  ].any((summary) => summary.license != null);
  if (!declared) return null;
  try {
    return await source.licenseText();
  } on CliException catch (e) {
    throw CliException(
      '${e.message}\n'
      'These widgets are licensed, and their notice has to be copied with '
      'them. Nothing was changed.',
    );
  }
}

/// How to use each widget in [result].
List<WidgetUsage> usageOf(AddResult result) => [
  for (final widget in result.widgets) _usage(result, widget),
];

WidgetUsage _usage(AddResult result, WidgetDetail widget) {
  final public = findPublicWidget(widget);
  if (public == null) return WidgetUsage(id: widget.id);
  // An entry point builds its own MaterialApp, so it cannot go in `home`.
  final isApp = p.posix.basename(public.file) == 'main.dart';
  return WidgetUsage(
    id: widget.id,
    name: public.name,
    import: packageImport(result.project, result.installDir, public),
    location: p.relative(
      p.joinAll([result.installDir, ...public.file.split('/')]),
      from: result.project.root,
    ),
    code: isApp
        ? 'runApp(${public.expression});'
        : 'home: ${public.expression},',
  );
}
