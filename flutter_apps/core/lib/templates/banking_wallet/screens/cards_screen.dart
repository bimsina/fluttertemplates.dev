import 'package:flutter/material.dart';

import '../models/bank_card.dart';
import '../state/spending_insights.dart';
import '../state/wallet_scope.dart';
import '../widgets/bank_card_view.dart';
import '../widgets/empty_state.dart';
import '../widgets/money_text.dart';
import '../widgets/tab_header.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/wallet_theme.dart';
import 'transaction_detail_screen.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final PageController _pages = PageController(viewportFraction: 0.9);
  int _index = 0;
  String? _revealedCardId;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pages.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = WalletScope.of(context).cards;
    if (cards.isEmpty) {
      return const Column(
        children: [
          TabHeader(title: 'Cards'),
          Expanded(
            child: EmptyState(
              icon: Icons.credit_card_off_outlined,
              title: 'No cards yet',
              message: 'Cards linked to your accounts will show up here.',
            ),
          ),
        ],
      );
    }

    final index = _index.clamp(0, cards.length - 1);
    final card = cards[index];
    final controls = _CardControls(
      card: card,
      revealed: _revealedCardId == card.id && !card.isFrozen,
      onRevealChanged: (reveal) =>
          setState(() => _revealedCardId = reveal ? card.id : null),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= twoColumnBreakpoint;
        final carouselWidth = twoColumns
            ? constraints.maxWidth * 0.5
            : constraints.maxWidth.clamp(0.0, 560.0);
        final carousel = _buildCarousel(cards, carouselWidth);

        if (twoColumns) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TabHeader(title: 'Cards'),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: carouselWidth, child: carousel),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(8, 0, 20, 24),
                        child: controls,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TabHeader(title: 'Cards'),
                  carousel,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: controls,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarousel(List<BankCard> cards, double width) {
    final scheme = Theme.of(context).colorScheme;
    final cardWidth = width * 0.9 - 12;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: cardWidth / BankCardView.aspectRatio,
          child: PageView.builder(
            controller: _pages,
            itemCount: cards.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Center(
                  child: BankCardView(
                    card: cards[index],
                    variant: index,
                    revealed: _revealedCardId == cards[index].id,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < cards.length; i++)
              Semantics(
                button: true,
                label: 'Show ${cards[i].label} card',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _goTo(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: i == _index ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? scheme.primary
                            : scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CardControls extends StatelessWidget {
  const _CardControls({
    required this.card,
    required this.revealed,
    required this.onRevealChanged,
  });

  final BankCard card;
  final bool revealed;
  final ValueChanged<bool> onRevealChanged;

  Future<void> _setFrozen(BuildContext context, bool frozen) async {
    final messenger = ScaffoldMessenger.of(context);
    final wallet = WalletScope.read(context);
    try {
      await wallet.setCardFrozen(card.id, frozen: frozen);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(
              frozen
                  ? '${card.label} card frozen. New payments will be declined.'
                  : '${card.label} card is active again.',
            ),
          ),
        );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            wallet.isDataStale
                ? 'Could not confirm the card\'s status. It may not match '
                      'what is shown here. Try again.'
                : 'Could not update the card. Try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final wallet = WalletScope.of(context);
    final account = wallet.accountById(card.accountId);
    final spent = cardSpendThisMonth(
      wallet.transactions,
      card.id,
      DateTime.now(),
    );
    final recent = wallet.transactions
        .where((transaction) => transaction.cardId == card.id)
        .take(3)
        .toList();
    final usage = card.monthlyLimitCents == 0
        ? 0.0
        : (spent / card.monthlyLimitCents).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Material(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.ac_unit),
                title: const Text('Freeze card'),
                subtitle: Text(
                  card.isFrozen
                      ? 'Payments are blocked'
                      : 'Blocks new payments',
                ),
                value: card.isFrozen,
                onChanged: wallet.isCardUpdating(card.id)
                    ? null
                    : (frozen) => _setFrozen(context, frozen),
              ),
              const Divider(indent: 16, endIndent: 16),
              SwitchListTile(
                secondary: const Icon(Icons.pin_outlined),
                title: const Text('Show card details'),
                subtitle: Text(
                  card.isFrozen ? 'Unavailable while frozen' : 'Number and CVV',
                ),
                value: revealed,
                onChanged: card.isFrozen ? null : onRevealChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Spent this month',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  MoneyText(spent, style: theme.textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: usage,
                  minHeight: 7,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Limit ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Flexible(
                    child: MoneyText(
                      card.monthlyLimitCents,
                      decimals: false,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (account != null)
                    Expanded(
                      child: Text(
                        'Linked to ${account.name}',
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            'Recent on this card',
            style: theme.textTheme.titleMedium,
          ),
        ),
        if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              'No purchases on this card yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final transaction in recent)
            TransactionTile(
              transaction: transaction,
              onTap: () => openTransaction(context, transaction.id),
            ),
      ],
    );
  }
}
