import 'package:flutter/material.dart';

import '../models/formatting.dart';
import '../models/restaurant.dart';
import 'common.dart';
import 'dish_art.dart';
import 'food_theme.dart';

/// Tile painted in the restaurant's own palette, with its signature dish
/// bleeding off the right edge.
class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  /// Base height. The grid scales this with the text size.
  static const height = 148.0;

  final Restaurant restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FoodTheme(
      seed: restaurant.seedColor,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          final ink = scheme.onPrimaryContainer;
          return Material(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(26),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  Positioned(
                    right: -44,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Hero(
                        tag: 'restaurant-art-${restaurant.id}',
                        child: DishArt(
                          kind: restaurant.kind,
                          size: 156,
                          scheme: scheme,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 122, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          restaurant.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: ink,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          restaurant.cuisine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ink.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            Fact(
                              icon: Icons.star_rounded,
                              label: restaurant.rating.toStringAsFixed(1),
                              color: ink,
                            ),
                            Fact(
                              icon: Icons.schedule_rounded,
                              label: '${restaurant.etaMinutes} min',
                              color: ink,
                            ),
                            Fact(
                              icon: Icons.delivery_dining_rounded,
                              label: restaurant.deliveryFeeCents == 0
                                  ? 'Free'
                                  : formatMoney(restaurant.deliveryFeeCents),
                              color: ink,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
