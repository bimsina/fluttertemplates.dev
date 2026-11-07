import 'package:flutter/material.dart';

import '../models/transaction.dart';

extension CategoryStyle on TransactionCategory {
  IconData get icon => switch (this) {
    TransactionCategory.groceries => Icons.local_grocery_store_outlined,
    TransactionCategory.dining => Icons.restaurant_outlined,
    TransactionCategory.transport => Icons.directions_transit_outlined,
    TransactionCategory.shopping => Icons.shopping_bag_outlined,
    TransactionCategory.bills => Icons.receipt_long_outlined,
    TransactionCategory.housing => Icons.home_outlined,
    TransactionCategory.entertainment => Icons.local_activity_outlined,
    TransactionCategory.health => Icons.favorite_outline,
    TransactionCategory.transfer => Icons.swap_horiz,
    TransactionCategory.income => Icons.south_west,
  };
}

/// A rounded tile holding a category's icon.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category, this.size = 44});

  final TransactionCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isIncome = category == TransactionCategory.income;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isIncome
            ? scheme.tertiaryContainer
            : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        category.icon,
        size: size * 0.5,
        color: isIncome ? scheme.onTertiaryContainer : scheme.onSurfaceVariant,
      ),
    );
  }
}
