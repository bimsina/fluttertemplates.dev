import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cart.dart';
import '../models/format.dart';

/// Returns the chosen discount, [Discount.none] to remove it, or null when
/// cancelled. Dialogs stay on the nested navigator so they keep the store and
/// theme that sit above it.
Future<Discount?> showDiscountDialog(
  BuildContext context, {
  required String title,
  required int baseCents,
  required Discount current,
}) => showDialog<Discount>(
  context: context,
  useRootNavigator: false,
  builder: (context) =>
      _DiscountDialog(title: title, baseCents: baseCents, current: current),
);

class _DiscountDialog extends StatefulWidget {
  const _DiscountDialog({
    required this.title,
    required this.baseCents,
    required this.current,
  });

  final String title;
  final int baseCents;
  final Discount current;

  @override
  State<_DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<_DiscountDialog> {
  static const _presets = [500, 1000, 1500, 2000];

  late DiscountKind _kind;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final current = widget.current;
    _kind = current.isNone ? DiscountKind.percent : current.kind;
    _controller = TextEditingController(
      text: current.isNone
          ? ''
          : current.kind == DiscountKind.percent
          ? formatBasisPoints(current.value).replaceAll('%', '')
          : (current.value / 100).toStringAsFixed(2),
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Both modes parse as two decimals: `12.5` is 1250 basis points or cents.
  Discount? get _discount {
    final value = parseMoney(_controller.text);
    if (value == null || value == 0) return null;
    if (_kind == DiscountKind.percent) {
      return value > 10000 ? null : Discount.percent(value);
    }
    return Discount.amount(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discount = _discount;
    final off = discount?.appliedTo(widget.baseCents) ?? 0;

    return AlertDialog(
      title: Text(widget.title),
      scrollable: true,
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<DiscountKind>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: DiscountKind.percent,
                  label: Text('Percent'),
                ),
                ButtonSegment(
                  value: DiscountKind.amount,
                  label: Text('Amount'),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (selection) => setState(() {
                _kind = selection.first;
                _controller.clear();
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                prefixText: _kind == DiscountKind.amount ? r'$ ' : null,
                suffixText: _kind == DiscountKind.percent ? '%' : null,
                hintText: '0',
              ),
            ),
            if (_kind == DiscountKind.percent) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in _presets)
                    ActionChip(
                      label: Text(formatBasisPoints(preset)),
                      onPressed: () =>
                          _controller.text = (preset ~/ 100).toString(),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              discount == null
                  ? 'On ${formatMoney(widget.baseCents)}'
                  : '${formatMoney(off)} off ${formatMoney(widget.baseCents)}, '
                        'leaves ${formatMoney(widget.baseCents - off)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (!widget.current.isNone)
          TextButton(
            onPressed: () => Navigator.of(context).pop(Discount.none),
            child: const Text('Remove'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: discount == null
              ? null
              : () => Navigator.of(context).pop(discount),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
