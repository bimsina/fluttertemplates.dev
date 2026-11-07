import 'package:flutter/material.dart';

import '../state/wallet_scope.dart';

/// Says that balances may be out of date and offers a refresh. Renders nothing
/// while the data is fresh.
class StaleDataNotice extends StatefulWidget {
  const StaleDataNotice({super.key});

  @override
  State<StaleDataNotice> createState() => _StaleDataNoticeState();
}

class _StaleDataNoticeState extends State<StaleDataNotice> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await WalletScope.read(context).refresh();
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!WalletScope.of(context).isDataStale) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.sync_problem, size: 20, color: scheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'We could not update your accounts. Balances and activity '
                'may be out of date.',
                style: theme.textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: _refreshing ? null : _refresh,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
