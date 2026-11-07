import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/format.dart';
import '../models/product.dart';
import '../models/stock_movement.dart';
import '../state/pos_scope.dart';
import '../widgets/panel.dart';
import '../widgets/pos_theme.dart';
import '../widgets/product_mark.dart';
import '../widgets/stock_indicators.dart';

enum _Mode {
  receive('Receive', 'Units received', StockMovementReason.received),
  remove('Remove', 'Units to remove', StockMovementReason.removed),
  recount('Recount', 'Counted on shelf', StockMovementReason.recount);

  const _Mode(this.label, this.fieldLabel, this.reason);

  final String label;
  final String fieldLabel;
  final StockMovementReason reason;
}

class StockAdjustScreen extends StatefulWidget {
  const StockAdjustScreen({super.key, required this.productId});

  final String productId;

  @override
  State<StockAdjustScreen> createState() => _StockAdjustScreenState();
}

class _StockAdjustScreenState extends State<StockAdjustScreen> {
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();
  late Future<List<StockMovement>> _movements;

  _Mode _mode = _Mode.receive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(() => setState(() {}));
    _loadMovements();
  }

  void _loadMovements() {
    _movements = PosScope.read(
      context,
    ).repository.fetchMovements(widget.productId);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int get _entered => int.tryParse(_quantityController.text) ?? 0;

  int _delta(Product product) => switch (_mode) {
    _Mode.receive => _entered,
    _Mode.remove => -_entered,
    _Mode.recount =>
      _quantityController.text.isEmpty ? 0 : _entered - product.stock,
  };

  void _nudge(int by) {
    final next = (_entered + by).clamp(0, 99999);
    _quantityController.text = '$next';
  }

  Future<void> _save(Product product) async {
    final store = PosScope.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final delta = _delta(product);
    final note = _noteController.text.trim();

    setState(() => _saving = true);
    try {
      await store.adjustStock(
        product: product,
        delta: delta,
        reason: _mode.reason,
        note: note.isEmpty ? null : note,
      );
    } catch (error, stackTrace) {
      debugPrint('Stock adjustment failed: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _saving = false;
        _loadMovements();
      });
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Could not confirm that change. Check the stock history before '
              'you try again.',
            ),
          ),
        );
      return;
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      _quantityController.clear();
      _noteController.clear();
      _loadMovements();
    });
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${product.name} now at ${product.stock + delta} units',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final product = store.productById(widget.productId);

    final form = _AdjustForm(
      product: product,
      mode: _mode,
      delta: _delta(product),
      saving: _saving,
      quantityController: _quantityController,
      noteController: _noteController,
      onMode: (mode) => setState(() {
        _mode = mode;
        _quantityController.clear();
      }),
      onNudge: _nudge,
      onSave: () => _save(product),
    );
    final history = _MovementLog(movements: _movements);

    return Scaffold(
      appBar: AppBar(title: const Text('Adjust stock')),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final summary = _ProductSummary(
              product: product,
              toneIndex: store.categoryIndex(product.categoryId),
              categoryName: store.categories
                  .firstWhere((category) => category.id == product.categoryId)
                  .name,
            );
            if (constraints.maxWidth >= 760) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    summary,
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: form),
                        const SizedBox(width: 10),
                        Expanded(child: history),
                      ],
                    ),
                  ],
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                summary,
                const SizedBox(height: 10),
                form,
                const SizedBox(height: 10),
                history,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductSummary extends StatelessWidget {
  const _ProductSummary({
    required this.product,
    required this.toneIndex,
    required this.categoryName,
  });

  final Product product;
  final int toneIndex;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ProductMark(product: product, toneIndex: toneIndex, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '$categoryName, ${product.barcode}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted?.tabular,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.stock}',
                    style: theme.textTheme.headlineMedium!.tabular,
                  ),
                  Text('on hand', style: muted),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          StockMeter(product: product),
          const SizedBox(height: 6),
          Text('Reorder at ${product.reorderPoint}', style: muted?.tabular),
        ],
      ),
    );
  }
}

class _AdjustForm extends StatelessWidget {
  const _AdjustForm({
    required this.product,
    required this.mode,
    required this.delta,
    required this.saving,
    required this.quantityController,
    required this.noteController,
    required this.onMode,
    required this.onNudge,
    required this.onSave,
  });

  final Product product;
  final _Mode mode;
  final int delta;
  final bool saving;
  final TextEditingController quantityController;
  final TextEditingController noteController;
  final ValueChanged<_Mode> onMode;
  final ValueChanged<int> onNudge;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final after = product.stock + delta;
    final valid = delta != 0 && after >= 0;

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<_Mode>(
            showSelectedIcon: false,
            segments: [
              for (final value in _Mode.values)
                ButtonSegment(value: value, label: Text(value.label)),
            ],
            selected: {mode},
            onSelectionChanged: (selection) => onMode(selection.first),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Decrease',
                icon: const Icon(Icons.remove_rounded),
                onPressed: () => onNudge(-1),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: quantityController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  style: theme.textTheme.titleLarge!.tabular,
                  decoration: InputDecoration(
                    labelText: mode.fieldLabel,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Increase',
                icon: const Icon(Icons.add_rounded),
                onPressed: () => onNudge(1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(
              hintText: 'Note, for example a delivery reference',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  after < 0
                      ? 'Only ${product.stock} on hand'
                      : delta == 0
                      ? 'No change yet'
                      : '${product.stock} to $after units',
                  style: theme.textTheme.bodyMedium!.tabular.copyWith(
                    color: after < 0 ? scheme.error : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              FilledButton(
                onPressed: valid && !saving ? onSave : null,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MovementLog extends StatelessWidget {
  const _MovementLog({required this.movements});

  final Future<List<StockMovement>> movements;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Panel(
      title: 'Stock history',
      child: FutureBuilder(
        future: movements,
        builder: (context, snapshot) {
          final entries = snapshot.data;
          if (entries == null) return const SizedBox(height: 60);
          if (entries.isEmpty) {
            return Text('No movements recorded yet.', style: muted);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry in entries.take(8))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          entry.delta > 0
                              ? '+${entry.delta}'
                              : '${entry.delta}',
                          style: theme.textTheme.titleSmall!.tabular.copyWith(
                            color: entry.delta > 0
                                ? scheme.primary
                                : scheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.reason.label,
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              [
                                '${formatDate(entry.createdAt)} '
                                    '${formatTime(entry.createdAt)}',
                                ?entry.note,
                              ].join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: muted,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${entry.stockAfter}', style: muted?.tabular),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
