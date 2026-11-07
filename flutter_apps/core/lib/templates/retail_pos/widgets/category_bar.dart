import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import '../models/product.dart';
import 'pos_theme.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<ProductCategory> categories;

  /// Null selects every category.
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.textScalerOf(context).scale(40),
      // A mouse cannot drag a horizontal list by default, which would strand
      // the last categories on a desktop browser.
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: PointerDeviceKind.values.toSet(),
          scrollbars: false,
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _Pill(
              label: 'All',
              selected: selectedId == null,
              onTap: () => onSelected(null),
            ),
            for (final (index, category) in categories.indexed)
              _Pill(
                label: category.name,
                toneIndex: index,
                selected: selectedId == category.id,
                onTap: () => onSelected(category.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.toneIndex,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? toneIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tone = toneIndex;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? scheme.inverseSurface : scheme.surface,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tone != null) ...[
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: PosTheme.categoryTone(scheme, tone).$1,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: selected
                          ? scheme.onInverseSurface
                          : scheme.onSurface,
                    ),
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
