import 'package:flutter/painting.dart';

import 'menu_item.dart';

/// The illustration drawn for a restaurant or a dish. See `DishArt`.
enum DishKind {
  pizza,
  ramen,
  burger,
  taco,
  salad,
  sushi,
  curry,
  cake,
  drink,
  fries,
}

class FoodCategory {
  const FoodCategory({
    required this.id,
    required this.label,
    required this.kind,
  });

  final String id;
  final String label;
  final DishKind kind;
}

class MenuSection {
  const MenuSection({required this.title, required this.items});

  final String title;
  final List<MenuItem> items;
}

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.categoryId,
    required this.seedColor,
    required this.kind,
    required this.rating,
    required this.reviewCount,
    required this.etaMinutes,
    required this.deliveryFeeCents,
    required this.minimumOrderCents,
    required this.distanceKm,
    required this.sections,
  });

  final String id;
  final String name;
  final String cuisine;
  final String categoryId;

  /// Seed for this restaurant's generated color scheme. The menu, cart and
  /// tracking screens all re-theme from it.
  final Color seedColor;
  final DishKind kind;
  final double rating;
  final int reviewCount;
  final int etaMinutes;
  final int deliveryFeeCents;
  final int minimumOrderCents;
  final double distanceKm;
  final List<MenuSection> sections;
}
