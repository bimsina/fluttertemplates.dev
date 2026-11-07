import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/card_terminal.dart';
import '../data/pos_repository.dart';
import '../models/cart.dart';
import '../models/format.dart';
import '../models/sale.dart';
import '../state/pos_scope.dart';
import '../state/pos_store.dart';
import '../widgets/keypad.dart';
import '../widgets/leader_row.dart';
import '../widgets/pos_theme.dart';
import '../widgets/torn_paper.dart';
import 'receipt_screen.dart';

enum _Method { cash, card }

enum _CardPhase { idle, waiting, authorizing, declined }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // A snapshot: the store's cart empties the moment the sale commits, and this
  // screen must keep showing the order until the receipt replaces it.
  late final PosStore _store;
  late final Cart _cart;
  late final CartTotals _totals;

  _Method _method = _Method.cash;
  int _tenderedCents = 0;
  bool _submitting = false;

  _CardPhase _cardPhase = _CardPhase.idle;
  String? _cardError;
  StreamSubscription<CardEvent>? _cardSubscription;

  int get _dueCents => _totals.totalCents;
  bool get _cardBusy =>
      _cardPhase == _CardPhase.waiting || _cardPhase == _CardPhase.authorizing;
  bool get _unresolved => _store.unresolvedSale != null;
  bool get _locked => _submitting || _cardBusy || _unresolved;

  @override
  void initState() {
    super.initState();
    _store = PosScope.read(context);
    _cart = _store.cart;
    _totals = _store.totals;
    _store.scanner.stop();
  }

  @override
  void dispose() {
    _cardSubscription?.cancel();
    _store.scanner.start();
    super.dispose();
  }

  // Cash

  void _addDigits(String digits) {
    final next = '$_tenderedCents$digits';
    if (next.length > 8) return;
    setState(() => _tenderedCents = int.parse(next));
  }

  void _backspace() => setState(() => _tenderedCents ~/= 10);

  void _completeCash() {
    if (_tenderedCents < _dueCents) return;
    _finish(
      CashPayment(
        tenderedCents: _tenderedCents,
        changeCents: _tenderedCents - _dueCents,
      ),
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (_method != _Method.cash || _unresolved || event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }
    final character = event.character;
    if (character != null && RegExp(r'^[0-9]$').hasMatch(character)) {
      _addDigits(character);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _backspace();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _completeCash();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // Card

  void _startCard() {
    setState(() {
      _cardPhase = _CardPhase.waiting;
      _cardError = null;
    });
    _cardSubscription = _store.cardTerminal
        .charge(_dueCents)
        .listen(
          (event) {
            switch (event) {
              case CardWaiting():
                setState(() => _cardPhase = _CardPhase.waiting);
              case CardAuthorizing():
                setState(() => _cardPhase = _CardPhase.authorizing);
              case CardDeclined(:final reason):
                setState(() {
                  _cardPhase = _CardPhase.declined;
                  _cardError = reason;
                });
              case CardApproved(:final brand, :final last4, :final authCode):
                setState(() => _cardPhase = _CardPhase.idle);
                _finish(
                  CardPayment(brand: brand, last4: last4, authCode: authCode),
                );
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('Card terminal failed: $error\n$stackTrace');
            _onTerminalLost();
          },
          // A charge ends in approved or declined. Ending any other way would
          // otherwise leave the screen waiting with back blocked.
          onDone: () {
            if (_cardBusy) _onTerminalLost();
          },
          cancelOnError: true,
        );
  }

  void _onTerminalLost() {
    setState(() {
      _cardPhase = _CardPhase.declined;
      _cardError =
          'The terminal stopped responding. Check it before charging again.';
    });
  }

  Future<void> _cancelCard() async {
    await _cardSubscription?.cancel();
    await _store.cardTerminal.cancel();
    if (mounted) setState(() => _cardPhase = _CardPhase.idle);
  }

  // Finish

  Future<void> _finish(Payment payment) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final navigator = Navigator.of(context);
    try {
      final result = await _store.completeSale(payment);
      if (!mounted) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) =>
              ReceiptScreen(sale: result.sale, lowStock: result.lowStock),
        ),
        (route) => route.isFirst,
      );
    } on SaleOutcomeUnknownException {
      if (mounted) setState(() => _submitting = false);
    } on InsufficientStockException catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      await showDialog<void>(
        context: context,
        useRootNavigator: false,
        builder: (context) => AlertDialog(
          title: const Text('Stock changed'),
          content: Text(
            'There is no longer enough of '
            '${error.productNames.join(', ')}. The sale was not recorded. '
            'If a card was charged, void it on the terminal.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to sale'),
            ),
          ],
        ),
      );
      if (mounted) navigator.pop();
    }
  }

  /// Resends the held sale. The payment is the one already taken.
  void _retrySale() {
    final draft = _store.unresolvedSale;
    if (draft != null) _finish(draft.payment);
  }

  Future<void> _abandonSale() async {
    final navigator = Navigator.of(context);
    final abandon = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (context) => AlertDialog(
        title: const Text('Stop retrying this sale?'),
        content: const Text(
          'It may already be recorded. Check the Sales screen before you '
          'charge this order again. If a card was charged, check the terminal '
          'too.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep retrying'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Stop retrying'),
          ),
        ],
      ),
    );
    if (abandon != true || !mounted) return;
    _store.abandonUnresolvedSale();
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final methodPane = _MethodPane(
      method: _method,
      locked: _locked,
      onMethod: (method) => setState(() => _method = method),
      child: _unresolved
          ? _UnresolvedSalePane(
              submitting: _submitting,
              onRetry: _retrySale,
              onAbandon: _abandonSale,
            )
          : _method == _Method.cash
          ? _CashPane(
              dueCents: _dueCents,
              tenderedCents: _tenderedCents,
              submitting: _submitting,
              onDigits: _addDigits,
              onBackspace: _backspace,
              onSetTendered: (cents) => setState(() => _tenderedCents = cents),
              onComplete: _completeCash,
            )
          : _CardPane(
              dueCents: _dueCents,
              phase: _cardPhase,
              error: _cardError,
              submitting: _submitting,
              terminal: _store.cardTerminal,
              onStart: _startCard,
              onCancel: _cancelCard,
            ),
    );

    return PopScope(
      canPop: !_locked,
      child: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Take payment'),
            leading: BackButton(
              onPressed: _locked
                  ? null
                  : () => Navigator.of(context).maybePop(),
            ),
          ),
          body: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 760 &&
                    constraints.maxHeight >= 560) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _OrderTape(cart: _cart, totals: _totals),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 6,
                          child: SingleChildScrollView(child: methodPane),
                        ),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DueBanner(
                        dueCents: _dueCents,
                        itemCount: _cart.itemCount,
                      ),
                      const SizedBox(height: 14),
                      methodPane,
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DueBanner extends StatelessWidget {
  const _DueBanner({required this.dueCents, required this.itemCount});

  final int dueCents;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            '$itemCount item${itemCount == 1 ? '' : 's'}, amount due',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          formatMoney(dueCents),
          style: theme.textTheme.headlineMedium!.tabular,
        ),
      ],
    );
  }
}

class _OrderTape extends StatelessWidget {
  const _OrderTape({required this.cart, required this.totals});

  final Cart cart;
  final CartTotals totals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = PosScope.read(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return TornPaper(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Order', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  for (final line in cart.lines)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: LeaderRow(
                        label: '${line.quantity} x ${line.product.name}',
                        value: formatMoney(line.netCents),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            LeaderRow(
              label: 'Subtotal',
              value: formatMoney(totals.grossCents),
              style: muted,
            ),
            if (totals.discountCents > 0)
              LeaderRow(
                label: 'Discounts',
                value: formatMoney(-totals.discountCents),
                style: muted,
              ),
            LeaderRow(
              label: store.profile.taxLabel,
              value: formatMoney(totals.taxCents),
              style: muted,
            ),
            const SizedBox(height: 6),
            LeaderRow(
              label: 'Amount due',
              value: formatMoney(totals.totalCents),
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodPane extends StatelessWidget {
  const _MethodPane({
    required this.method,
    required this.locked,
    required this.onMethod,
    required this.child,
  });

  final _Method method;
  final bool locked;
  final ValueChanged<_Method> onMethod;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<_Method>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: _Method.cash,
              icon: Icon(Icons.payments_outlined),
              label: Text('Cash'),
            ),
            ButtonSegment(
              value: _Method.card,
              icon: Icon(Icons.credit_card_rounded),
              label: Text('Card'),
            ),
          ],
          selected: {method},
          onSelectionChanged: locked
              ? null
              : (selection) => onMethod(selection.first),
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

/// Replaces the payment controls when a sale's outcome is unknown. Taking a
/// new payment here could charge the customer twice, so retry is the way on.
class _UnresolvedSalePane extends StatelessWidget {
  const _UnresolvedSalePane({
    required this.submitting,
    required this.onRetry,
    required this.onAbandon,
  });

  final bool submitting;
  final VoidCallback onRetry;
  final VoidCallback onAbandon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            'We could not confirm this sale, and it may be recorded already. '
            'Retrying is safe: it can only be recorded once, and the customer '
            'pays nothing more.',
            style: theme.textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: submitting ? null : onRetry,
            child: Text(submitting ? 'Checking' : 'Retry sale'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: submitting ? null : onAbandon,
          child: const Text('Stop retrying'),
        ),
      ],
    );
  }
}

class _CashPane extends StatelessWidget {
  const _CashPane({
    required this.dueCents,
    required this.tenderedCents,
    required this.submitting,
    required this.onDigits,
    required this.onBackspace,
    required this.onSetTendered,
    required this.onComplete,
  });

  final int dueCents;
  final int tenderedCents;
  final bool submitting;
  final ValueChanged<String> onDigits;
  final VoidCallback onBackspace;
  final ValueChanged<int> onSetTendered;
  final VoidCallback onComplete;

  /// Exact change, then the note combinations a customer is likely to hand
  /// over.
  List<int> get _quickAmounts {
    final amounts = <int>{dueCents};
    for (final step in const [500, 1000, 2000, 5000, 10000]) {
      amounts.add(((dueCents + step - 1) ~/ step) * step);
    }
    return amounts.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enough = tenderedCents >= dueCents;
    final difference = tenderedCents - dueCents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: enough ? scheme.primaryContainer : scheme.surface,
            borderRadius: BorderRadius.circular(PosTheme.tileRadius),
          ),
          child: Row(
            children: [
              Expanded(
                child: _Readout(
                  label: 'Tendered',
                  value: formatMoney(tenderedCents),
                  color: enough ? scheme.onPrimaryContainer : scheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Readout(
                  label: enough ? 'Change due' : 'Still due',
                  value: formatMoney(difference.abs()),
                  color: enough
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final (index, amount) in _quickAmounts.indexed) ...[
              if (index > 0) const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  onPressed: () => onSetTendered(amount),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      index == 0 ? 'Exact' : formatMoney(amount),
                      style: theme.textTheme.labelLarge!.tabular,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Keypad(onDigits: onDigits, onBackspace: onBackspace, keyHeight: 54),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: enough && !submitting ? onComplete : null,
            child: Text(
              enough
                  ? 'Complete sale'
                  : 'Enter ${formatMoney(dueCents)} or more',
            ),
          ),
        ),
      ],
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout({
    required this.label,
    required this.value,
    required this.color,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: color)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: theme.textTheme.headlineMedium!.tabular.copyWith(
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardPane extends StatefulWidget {
  const _CardPane({
    required this.dueCents,
    required this.phase,
    required this.error,
    required this.submitting,
    required this.terminal,
    required this.onStart,
    required this.onCancel,
  });

  final int dueCents;
  final _CardPhase phase;
  final String? error;
  final bool submitting;
  final CardTerminal terminal;
  final VoidCallback onStart;
  final VoidCallback onCancel;

  @override
  State<_CardPane> createState() => _CardPaneState();
}

class _CardPaneState extends State<_CardPane> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final terminal = widget.terminal;
    final busy =
        widget.phase == _CardPhase.waiting ||
        widget.phase == _CardPhase.authorizing;
    final declined = widget.phase == _CardPhase.declined;

    final (icon, title, detail) = switch (widget.phase) {
      _CardPhase.idle when widget.submitting => (
        Icons.check_circle_rounded,
        'Approved',
        'Recording the sale.',
      ),
      _CardPhase.idle => (
        Icons.contactless_rounded,
        'Ready to charge',
        'The amount will be sent to the card terminal.',
      ),
      _CardPhase.waiting => (
        Icons.contactless_rounded,
        'Tap, insert or swipe',
        'Waiting for the customer.',
      ),
      _CardPhase.authorizing => (
        Icons.sync_rounded,
        'Authorizing',
        'Contacting the card issuer.',
      ),
      _CardPhase.declined => (
        Icons.credit_card_off_rounded,
        'Card declined',
        widget.error ?? 'Try another card.',
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(
            color: declined ? scheme.errorContainer : scheme.surface,
            borderRadius: BorderRadius.circular(PosTheme.tileRadius),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 44,
                color: declined ? scheme.onErrorContainer : scheme.primary,
              ),
              const SizedBox(height: 10),
              Text(
                formatMoney(widget.dueCents),
                style: theme.textTheme.headlineMedium!.tabular.copyWith(
                  color: declined ? scheme.onErrorContainer : scheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: declined ? scheme.onErrorContainer : scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: declined
                      ? scheme.onErrorContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
              if (busy) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: busy
              ? OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                )
              : FilledButton(
                  onPressed: widget.dueCents > 0 && !widget.submitting
                      ? widget.onStart
                      : null,
                  child: Text(declined ? 'Try again' : 'Charge card'),
                ),
        ),
        // Demo control for the failure path. Delete with the simulator.
        if (terminal is SimulatedCardTerminal) ...[
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: const Text('Simulate a decline'),
            subtitle: const Text('Demo terminal only'),
            value: terminal.declineNext,
            onChanged: busy
                ? null
                : (value) => setState(() => terminal.declineNext = value),
          ),
        ],
      ],
    );
  }
}
