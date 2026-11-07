import 'dart:async';

import 'package:flutter/material.dart';

enum _Status { uploading, done, failed }

class _DemoFile {
  const _DemoFile(this.name, this.megabytes, this.icon, {this.flaky = false});

  final String name;
  final double megabytes;
  final IconData icon;

  /// Drops the connection once at 60%, to show the retry path.
  final bool flaky;
}

const _maxMegabytes = 10.0;

const _desktop = [
  _DemoFile('brief.pdf', 2.4, Icons.picture_as_pdf_outlined),
  _DemoFile('hero.png', 4.8, Icons.image_outlined),
  _DemoFile('data.csv', 7.1, Icons.table_chart_outlined, flaky: true),
  _DemoFile('demo.mov', 86, Icons.movie_outlined),
];

class _Upload {
  _Upload(this.file);

  final _DemoFile file;
  var status = _Status.uploading;
  var progress = 0.0;
  var failedOnce = false;
  Timer? timer;
}

class FileUploadDropzone extends StatefulWidget {
  const FileUploadDropzone({super.key});

  @override
  State<FileUploadDropzone> createState() => _FileUploadDropzoneState();
}

class _FileUploadDropzoneState extends State<FileUploadDropzone> {
  final _uploads = <_Upload>[];
  var _browseIndex = 0;

  @override
  void dispose() {
    for (final upload in _uploads) {
      upload.timer?.cancel();
    }
    super.dispose();
  }

  void _add(_DemoFile file) {
    if (file.megabytes > _maxMegabytes) {
      _toast('${file.name} is over the ${_maxMegabytes.round()} MB limit');
      return;
    }
    if (_uploads.any((u) => u.file == file)) {
      _toast('${file.name} is already in the list');
      return;
    }
    final upload = _Upload(file);
    setState(() => _uploads.add(upload));
    _run(upload);
  }

  /// A stand-in for an upload stream: smaller files finish sooner.
  void _run(_Upload upload) {
    final step = 0.35 / upload.file.megabytes / 2;
    upload.timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      setState(() {
        upload.progress += step;
        if (upload.file.flaky && !upload.failedOnce && upload.progress >= 0.6) {
          upload
            ..status = _Status.failed
            ..failedOnce = true;
          timer.cancel();
        } else if (upload.progress >= 1) {
          upload
            ..status = _Status.done
            ..progress = 1;
          timer.cancel();
        }
      });
    });
  }

  void _retry(_Upload upload) {
    setState(() {
      upload
        ..status = _Status.uploading
        ..progress = 0;
    });
    _run(upload);
  }

  void _remove(_Upload upload) {
    upload.timer?.cancel();
    setState(() => _uploads.remove(upload));
  }

  /// Swap this for your platform's file picker; it should call [_add].
  void _browse() {
    final accepted =
        _desktop.where((f) => f.megabytes <= _maxMegabytes).toList();
    final next = accepted.where((f) => !_uploads.any((u) => u.file == f));
    if (next.isEmpty) {
      _toast('Every sample file is already added');
      return;
    }
    _add(next.elementAt(_browseIndex++ % next.length));
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final allDone = _uploads.isNotEmpty &&
        _uploads.every((u) => u.status == _Status.done);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload files')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DragTarget<_DemoFile>(
            onAcceptWithDetails: (details) => _add(details.data),
            builder: (context, candidates, _) =>
                _Dropzone(hovering: candidates.isNotEmpty, onBrowse: _browse),
          ),
          const SizedBox(height: 16),
          Text(
            'Drag a sample file into the box',
            style: theme.textTheme.labelMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final file in _desktop) _FileChip(file: file)],
          ),
          const SizedBox(height: 12),
          for (final upload in _uploads)
            _UploadRow(
              key: ObjectKey(upload),
              upload: upload,
              onRetry: () => _retry(upload),
              onRemove: () => _remove(upload),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: allDone
                ? () => _toast('${_uploads.length} files attached')
                : null,
            child: const Text('Attach files'),
          ),
        ],
      ),
    );
  }
}

class _Dropzone extends StatelessWidget {
  const _Dropzone({required this.hovering, required this.onBrowse});

  final bool hovering;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: hovering ? scheme.primary : scheme.outline,
        strokeWidth: hovering ? 2 : 1.5,
      ),
      child: Material(
        color: hovering
            ? scheme.primaryContainer
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(_DashedBorderPainter.radius),
        child: InkWell(
          onTap: onBrowse,
          borderRadius: BorderRadius.circular(_DashedBorderPainter.radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  AnimatedScale(
                    scale: hovering ? 1.15 : 1,
                    duration: const Duration(milliseconds: 140),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: 36,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hovering ? 'Drop to upload' : 'Drop files or tap to browse',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Up to ${_maxMegabytes.round()} MB each',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FileChip extends StatelessWidget {
  const _FileChip({required this.file});

  final _DemoFile file;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget chip({double elevation = 0}) => Material(
          elevation: elevation,
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(file.icon, size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(file.name, style: theme.textTheme.labelMedium),
              ],
            ),
          ),
        );

    return Draggable<_DemoFile>(
      data: file,
      feedback: chip(elevation: 6),
      childWhenDragging: Opacity(opacity: 0.4, child: chip()),
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: chip()),
    );
  }
}

class _UploadRow extends StatelessWidget {
  const _UploadRow({
    super.key,
    required this.upload,
    required this.onRetry,
    required this.onRemove,
  });

  final _Upload upload;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final file = upload.file;
    final failed = upload.status == _Status.failed;

    final detail = switch (upload.status) {
      _Status.uploading => '${(upload.progress * 100).round()}% '
          'of ${file.megabytes} MB',
      _Status.done => '${file.megabytes} MB',
      _Status.failed => 'Upload failed',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            failed
                ? Icons.error_outline
                : upload.status == _Status.done
                    ? Icons.check_circle_outline
                    : file.icon,
            color: failed ? scheme.error : scheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: failed ? scheme.error : scheme.onSurfaceVariant,
                  ),
                ),
                if (upload.status == _Status.uploading) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: upload.progress,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ],
            ),
          ),
          if (failed)
            IconButton(
              tooltip: 'Retry ${file.name}',
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
            ),
          IconButton(
            tooltip: upload.status == _Status.uploading
                ? 'Cancel ${file.name}'
                : 'Remove ${file.name}',
            onPressed: onRemove,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.strokeWidth});

  static const radius = 16.0;
  static const _dash = 7.0;
  static const _space = 5.0;

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(strokeWidth / 2),
          const Radius.circular(radius),
        ),
      );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    for (final metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _space) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
