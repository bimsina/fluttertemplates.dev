import 'restaurant.dart';

class ItemOption {
  const ItemOption({required this.id, required this.name, this.priceCents = 0});

  final String id;
  final String name;

  /// Added to the item price when this option is selected.
  final int priceCents;
}

class OptionGroup {
  const OptionGroup({
    required this.id,
    required this.title,
    required this.options,
    this.minSelected = 0,
    this.maxSelected = 1,
  });

  final String id;
  final String title;
  final List<ItemOption> options;
  final int minSelected;
  final int maxSelected;

  bool get isRequired => minSelected > 0;
  bool get isSingleChoice => maxSelected == 1;

  String get hint {
    if (isSingleChoice) return isRequired ? 'Choose 1' : 'Optional';
    if (isRequired) return 'Choose $minSelected to $maxSelected';
    return 'Up to $maxSelected';
  }
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.kind,
    this.popular = false,
    this.optionGroups = const [],
  });

  final String id;
  final String name;
  final String description;
  final int priceCents;
  final DishKind kind;
  final bool popular;
  final List<OptionGroup> optionGroups;
}
