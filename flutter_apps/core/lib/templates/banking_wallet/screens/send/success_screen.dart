import 'package:flutter/material.dart';

import '../../models/formatting.dart';
import '../../state/wallet_scope.dart';
import '../../widgets/money_text.dart';
import '../../widgets/stale_data_notice.dart';
import '../transaction_detail_screen.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    super.key,
    required this.transactionId,
    required this.payeeName,
    required this.accountId,
    required this.amountCents,
  });

  final String transactionId;
  final String payeeName;
  final String accountId;
  final int amountCents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final wallet = WalletScope.of(context);
    final account = wallet.accountById(accountId);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 48),
                          Center(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.4, end: 1),
                              duration: const Duration(milliseconds: 520),
                              curve: Curves.elasticOut,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 46,
                                  color: scheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          Text(
                            '${formatCents(amountCents)} sent',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'to $payeeName',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          if (account != null) ...[
                            const SizedBox(height: 26),
                            Text(
                              '${account.name} balance',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            MoneyText(
                              account.balanceCents,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge,
                            ),
                          ],
                          const SizedBox(height: 20),
                          const StaleDataNotice(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => TransactionDetailScreen(
                          transactionId: transactionId,
                        ),
                      ),
                    ),
                    child: const Text('View receipt'),
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
