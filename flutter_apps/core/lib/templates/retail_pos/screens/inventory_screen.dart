import 'package:flutter/material.dart';

import '../models/format.dart';
import '../models/product.dart';
import '../state/pos_scope.dart';
import '../state/pos_store.dart';
import '../widgets/panel.dart';
import '../widgets/pos_theme.dart';
import '../widgets/product_mark.dart';
import '../widgets/stock_indicators.dart';
import 'stock_adjust_screen.dart';

enum _Filter {
  all('All'),
  alerts('Needs attention');

  const _Filter(this.label);

  final String label;
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _query = '';
  _Filter _filter = _Filter.all;

  /// Most urgent first, then alphabetical.
  List<Product> _rows(List<Product> products) {
    final query = _query.trim().toLowerCase();
    final rows = products.where((product) {
      if (_filter == _Filter.alerts && product.level == StockLevel.healthy) {
        return false;
      }
      return query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.barcode.contains(query) ||
          product.sku.contains(query);
    }).toList();
    rows.sort((a, b) {
      final urgency = b.level.index.compareTo(a.level.index);
      return urgency != 0 ? urgency : a.name.compareTo(b.name);
    });
    return rows;
  }

  void _open(Product product) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => StockAdjustScreen(productId: product.id),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = PosScope.of(context);
    final products = store.products;
    final rows = _rows(products);
    final units = products.fold(0, (sum, product) => sum + product.stock);
    final value = products.fold(
      0,
      (sum, product) => sum + product.stockValueCents,
    );
    final alerts = store.alerts;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 680;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Inventory', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    StatGrid(
                      minWidth: 104,
                      children: [
                        StatTile(
                          label: 'Products',
                          value: '${products.length}',
                        ),
                        StatTile(label: 'Units on hand', value: '$units'),
                        StatTile(
                          label: 'Value at cost',
                          value: formatMoney(value),
                        ),
                      ],
                    ),
                    if (alerts.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _AlertBanner(
                        alerts: alerts,
                        active: _filter == _Filter.alerts,
                        onToggle: () => setState(
                          () => _filter = _filter == _Filter.alerts
                              ? _Filter.all
                              : _Filter.alerts,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: const InputDecoration(
                        hintText: 'Search by name, code or barcode',
                        prefixIcon: Icon(Icons.search_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final filter in _Filter.values)
                          ChoiceChip(
                            label: Text(filter.label),
                            selected: _filter == filter,
                            showCheckmark: false,
                            onSelected: (_) => setState(() => _filter = filter),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (wide && rows.isNotEmpty) const _ColumnHeadings(),
                  ],
                ),
              ),
            ),
            if (rows.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: EmptyMessage(
                    icon: Icons.inventory_2_outlined,
                    message: 'Nothing here. Stock is in good shape.',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) => _InventoryRow(
                    key: ValueKey(rows[index].id),
                    product: rows[index],
                    store: store,
                    wide: wide,
                    onTap: () => _open(rows[index]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({
    required this.alerts,
    required this.active,
    required this.onToggle,
  });

  final List<Product> alerts;
  final bool active;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final out = alerts.where((p) => p.level == StockLevel.out).length;
    final low = alerts.length - out;
    final summary = [
      if (low > 0) '$low running low',
      if (out > 0) '$out sold out',
    ].join(', ');

    return Material(
      color: scheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(PosTheme.tileRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: scheme.onTertiaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  summary,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onTertiaryContainer,
                  ),
                ),
              ),
              Text(
                active ? 'Show all' : 'Review',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onTertiaryContainer,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onTertiaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColumnHeadings extends StatelessWidget {
  const _ColumnHeadings();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(66, 6, 6, 6),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text('Product', style: style)),
          Expanded(flex: 4, child: Text('Stock level', style: style)),
          SizedBox(
            width: 64,
            child: Text('On hand', textAlign: TextAlign.end, style: style),
          ),
          SizedBox(
            width: 64,
            child: Text('Reorder', textAlign: TextAlign.end, style: style),
          ),
          SizedBox(
            width: 84,
            child: Text('Value', textAlign: TextAlign.end, style: style),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({
    super.key,
    required this.product,
    required this.store,
    required this.wide,
    required this.onTap,
  });

  final Product product;
  final PosStore store;
  final bool wide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final tabular = theme.textTheme.bodyMedium!.tabular;
    final level = product.level;
    final stockStyle = theme.textTheme.titleSmall!.tabular.copyWith(
      color: level == StockLevel.healthy
          ? scheme.onSurface
          : stockColor(scheme, level),
    );
    final mark = ProductMark(
      product: product,
      toneIndex: store.categoryIndex(product.categoryId),
    );
    final title = Text(
      product.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleSmall,
    );

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(PosTheme.tileRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
          child: wide
              ? Row(
                  children: [
                    mark,
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          Text(
                            product.barcode,
                            maxLines: 1,
                            style: muted?.tabular,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StockMeter(product: product),
                            if (level != StockLevel.healthy) ...[
                              const SizedBox(height: 4),
                              _LevelLabel(level: level),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 64,
                      child: Text(
                        '${product.stock}',
                        textAlign: TextAlign.end,
                        style: stockStyle,
                      ),
                    ),
                    SizedBox(
                      width: 64,
                      child: Text(
                        '${product.reorderPoint}',
                        textAlign: TextAlign.end,
                        style: tabular.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    SizedBox(
                      width: 84,
                      child: Text(
                        formatMoney(product.stockValueCents),
                        textAlign: TextAlign.end,
                        style: tabular,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                )
              : Row(
                  children: [
                    mark,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          const SizedBox(height: 4),
                          StockMeter(product: product),
                          if (level != StockLevel.healthy) ...[
                            const SizedBox(height: 4),
                            _LevelLabel(level: level),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${product.stock}', style: stockStyle),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _LevelLabel extends StatelessWidget {
  const _LevelLabel({required this.level});

  final StockLevel level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = stockColor(theme.colorScheme, level);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          level == StockLevel.out
              ? Icons.block_rounded
              : Icons.warning_amber_rounded,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 3),
        Text(
          level == StockLevel.out ? 'Sold out' : 'Reorder soon',
          style: theme.textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
