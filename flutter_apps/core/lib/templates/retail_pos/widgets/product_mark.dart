import 'package:flutter/material.dart';

import '../models/product.dart';
import 'pos_theme.dart';

/// Small monogram square for rows in lists.
class ProductMark extends StatelessWidget {
  const ProductMark({
    super.key,
    required this.product,
    required this.toneIndex,
    this.size = 44,
  });

  final Product product;
  final int toneIndex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (background, foreground) = PosTheme.categoryTone(
      theme.colorScheme,
      toneIndex,
    );
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: Text(
        product.monogram,
        style: theme.textTheme.titleSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
