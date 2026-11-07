class WidgetDependency {
  const WidgetDependency({required this.name, required this.version});

  factory WidgetDependency.fromJson(Map<String, dynamic> json) =>
      WidgetDependency(
        name: json['name'] as String,
        version: json['version'] as String? ?? 'any',
      );

  final String name;
  final String version;

  Map<String, dynamic> toJson() => {'name': name, 'version': version};
}

/// An entry of `index.json`.
class WidgetSummary {
  const WidgetSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.categoryTitle,
    required this.url,
    required this.loc,
    required this.flutterWidgets,
    required this.dependencies,
    this.license,
    this.licenseUrl,
  });

  /// Reads the fields shared by `index.json` entries and `<id>.json` files.
  /// `files` differs between the two, so it is handled by the callers.
  factory WidgetSummary.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as String? ?? '';
    return WidgetSummary(
      id: json['id'] as String,
      title: json['title'] as String? ?? json['id'] as String,
      description: json['description'] as String? ?? '',
      category: category,
      categoryTitle: json['categoryTitle'] as String? ?? category,
      url: json['url'] as String? ?? '',
      loc: json['loc'] as int? ?? 0,
      flutterWidgets: [
        for (final name in json['flutterWidgets'] as List<dynamic>? ?? [])
          name as String,
      ],
      dependencies: [
        for (final dep in json['dependencies'] as List<dynamic>? ?? [])
          WidgetDependency.fromJson(dep as Map<String, dynamic>),
      ],
      license: json['license'] as String?,
      licenseUrl: json['licenseUrl'] as String?,
    );
  }

  final String id;
  final String title;
  final String description;
  final String category;
  final String categoryTitle;
  final String url;
  final int loc;
  final List<String> flutterWidgets;
  final List<WidgetDependency> dependencies;

  /// The license's name, such as `MIT`. Null if the registry declares none.
  final String? license;
  final String? licenseUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'categoryTitle': categoryTitle,
    'url': url,
    'loc': loc,
    'flutterWidgets': flutterWidgets,
    'dependencies': [for (final dep in dependencies) dep.toJson()],
    'license': ?license,
    'licenseUrl': ?licenseUrl,
  };
}

class WidgetFile {
  const WidgetFile({required this.path, required this.content});

  factory WidgetFile.fromJson(Map<String, dynamic> json) => WidgetFile(
    path: json['path'] as String,
    content: json['content'] as String,
  );

  /// Relative to the library root, with `/` separators.
  final String path;
  final String content;
}

/// A `<id>.json` file: a widget and its sources.
class WidgetDetail {
  const WidgetDetail({required this.summary, required this.files});

  factory WidgetDetail.fromJson(Map<String, dynamic> json) => WidgetDetail(
    summary: WidgetSummary.fromJson(json),
    files: [
      for (final file in json['files'] as List<dynamic>)
        WidgetFile.fromJson(file as Map<String, dynamic>),
    ],
  );

  final WidgetSummary summary;
  final List<WidgetFile> files;

  String get id => summary.id;
}

class RegistryIndex {
  const RegistryIndex({required this.version, required this.widgets});

  final int version;
  final List<WidgetSummary> widgets;

  /// Categories in title order, each with its widget count.
  List<CategoryInfo> get categories {
    final byId = <String, CategoryInfo>{};
    for (final widget in widgets) {
      final known = byId[widget.category];
      byId[widget.category] = CategoryInfo(
        id: widget.category,
        title: widget.categoryTitle,
        count: (known?.count ?? 0) + 1,
      );
    }
    return byId.values.toList()..sort((a, b) => a.title.compareTo(b.title));
  }
}

class CategoryInfo {
  const CategoryInfo({
    required this.id,
    required this.title,
    required this.count,
  });

  final String id;
  final String title;
  final int count;

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'count': count};
}
