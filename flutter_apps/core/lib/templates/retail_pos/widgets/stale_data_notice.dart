import 'package:flutter/material.dart';

import '../state/pos_scope.dart';

/// Says that stock and sales may be out of date and offers a refresh. Renders
/// nothing while the data is fresh.
class StaleDataNotice extends StatefulWidget {
  const StaleDataNotice({
    super.key,
    this.margin = EdgeInsets.zero,
    this.bottomGap = 0,
  });

  final EdgeInsets margin;

  /// Space below the notice, only taken up while it shows.
  final double bottomGap;

  @override
  State<StaleDataNotice> createState() => _StaleDataNoticeState();
}

class _StaleDataNoticeState extends State<StaleDataNotice> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await PosScope.read(context).refresh();
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!PosScope.of(context).isDataStale) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: widget.margin.copyWith(
        bottom: widget.margin.bottom + widget.bottomGap,
      ),
      child: Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.sync_problem,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Could not update from the server. Stock and sales may '
                      'be out of date.',
                      style: theme.textTheme.bodySmall,
                    ),
                    TextButton(
                      onPressed: _refreshing ? null : _refresh,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
