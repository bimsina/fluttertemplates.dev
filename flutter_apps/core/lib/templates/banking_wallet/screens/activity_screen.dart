import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../widgets/tab_header.dart';
import '../widgets/transaction_browser.dart';
import '../widgets/wallet_theme.dart';
import 'transaction_detail_screen.dart';

/// All transactions. On wide layouts the selected transaction opens in a pane
/// beside the list instead of on a new screen.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final split = constraints.maxWidth >= twoColumnBreakpoint;

        void open(Transaction transaction) {
          if (split) {
            setState(() => _selectedId = transaction.id);
          } else {
            openTransaction(context, transaction.id);
          }
        }

        final list = Column(
          children: [
            const TabHeader(title: 'Activity'),
            Expanded(
              child: TransactionBrowser(
                selectedId: split ? _selectedId : null,
                onOpen: open,
              ),
            ),
          ],
        );
        if (!split) return list;

        final selectedId = _selectedId;
        return Row(
          children: [
            SizedBox(width: 400, child: list),
            const VerticalDivider(width: 1),
            Expanded(
              child: selectedId == null
                  ? const TransactionDetailPlaceholder()
                  : TransactionDetailView(
                      key: ValueKey(selectedId),
                      transactionId: selectedId,
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// A full-screen transaction list for a subset, such as one month's groceries.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({
    super.key,
    required this.title,
    required this.scope,
  });

  final String title;
  final bool Function(Transaction transaction) scope;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: TransactionBrowser(
              scope: scope,
              onOpen: (t) => openTransaction(context, t.id),
            ),
          ),
        ),
      ),
    );
  }
}
