import 'package:flutter/material.dart';

import '../models/order.dart';
import '../models/restaurant.dart';
import '../state/app_scope.dart';
import '../widgets/common.dart';
import '../widgets/dish_art.dart';
import '../widgets/food_theme.dart';
import '../widgets/layout.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_screen.dart';
import 'tracking_screen.dart';

typedef _HomeData = ({
  List<FoodCategory> categories,
  List<Restaurant> restaurants,
});

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _maxWidth = 1040.0;

  Future<_HomeData>? _data;
  String? _categoryId;
  final _search = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= _load();
  }

  Future<_HomeData> _load() async {
    final repository = RepositoryScope.of(context);
    final categories = repository.fetchCategories();
    final restaurants = repository.fetchRestaurants();
    return (categories: await categories, restaurants: await restaurants);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Restaurant> _filter(List<Restaurant> all) {
    final query = _search.text.trim().toLowerCase();
    bool matchesQuery(Restaurant restaurant) {
      if (query.isEmpty) return true;
      return restaurant.name.toLowerCase().contains(query) ||
          restaurant.cuisine.toLowerCase().contains(query) ||
          restaurant.sections.any(
            (section) => section.items.any(
              (item) => item.name.toLowerCase().contains(query),
            ),
          );
    }

    return all
        .where((r) => _categoryId == null || r.categoryId == _categoryId)
        .where(matchesQuery)
        .toList();
  }

  void _resetFilters() {
    _search.clear();
    setState(() => _categoryId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<_HomeData>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return EmptyState(
                title: 'Could not load restaurants',
                message: 'Check your connection and try again.',
                actionLabel: 'Retry',
                onAction: () => setState(() => _data = _load()),
              );
            }
            final data = snapshot.data;
            return LayoutBuilder(
              builder: (context, constraints) {
                final gutter = centeredGutter(constraints.maxWidth, _maxWidth);
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 0),
                      sliver: SliverToBoxAdapter(
                        child: _Header(
                          search: _search,
                          onSearchChanged: () => setState(() {}),
                        ),
                      ),
                    ),
                    if (data == null)
                      ..._loading(gutter)
                    else
                      ..._content(data, gutter),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _loading(double gutter) => [
    SliverPadding(
      padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 0),
      sliver: SliverList.separated(
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) =>
            const SkeletonBox(height: RestaurantCard.height, radius: 26),
      ),
    ),
  ];

  List<Widget> _content(_HomeData data, double gutter) {
    final restaurants = _filter(data.restaurants);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final category = data.categories
        .where((c) => c.id == _categoryId)
        .firstOrNull;

    return [
      SliverToBoxAdapter(
        child: _CategoryStrip(
          categories: data.categories,
          selectedId: _categoryId,
          gutter: gutter,
          onSelected: (id) => setState(() => _categoryId = id),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: gutter),
        sliver: const SliverToBoxAdapter(child: _ActiveOrderBanner()),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 10),
        sliver: SliverToBoxAdapter(
          child: Text(
            category == null ? 'Near you' : category.label,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      if (restaurants.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            title: 'Nothing on the menu',
            message: 'No restaurants match your search. Try something else.',
            actionLabel: 'Clear filters',
            onAction: _resetFilters,
          ),
        )
      else
        SliverPadding(
          padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 24),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              mainAxisExtent: RestaurantCard.height * textScale,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return RestaurantCard(
                restaurant: restaurant,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => RestaurantScreen(restaurant: restaurant),
                  ),
                ),
              );
            },
          ),
        ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.search, required this.onSearchChanged});

  final TextEditingController search;
  final VoidCallback onSearchChanged;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Breakfast, delivered';
    if (hour < 16) return 'What is for lunch?';
    return 'What is for dinner?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final address = CartScope.of(context).address;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Fact(
          icon: Icons.place_rounded,
          label: address?.singleLine ?? 'Add your address at checkout',
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(height: 6),
        Text(_greeting(), style: theme.textTheme.headlineMedium),
        const SizedBox(height: 14),
        ListenableBuilder(
          listenable: search,
          builder: (context, _) => TextField(
            controller: search,
            onChanged: (_) => onSearchChanged(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search dishes or restaurants',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        search.clear();
                        onSearchChanged();
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categories,
    required this.selectedId,
    required this.gutter,
    required this.onSelected,
  });

  final List<FoodCategory> categories;
  final String? selectedId;
  final double gutter;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.textScalerOf(context).scale(16) + 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 0),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: 'All',
              selected: selectedId == null,
              onTap: () => onSelected(null),
              child: Icon(
                Icons.apps_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }
          final category = categories[index - 1];
          final selected = selectedId == category.id;
          return _CategoryChip(
            label: category.label,
            selected: selected,
            // Tapping the active category turns the filter off.
            onTap: () => onSelected(selected ? null : category.id),
            child: DishArt(kind: category.kind, size: 48),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 68,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? scheme.primaryContainer
                      : scheme.surfaceContainer,
                  border: Border.all(
                    color: selected ? scheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: child,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Live summary of the newest order in progress, shown above the list.
class _ActiveOrderBanner extends StatelessWidget {
  const _ActiveOrderBanner();

  @override
  Widget build(BuildContext context) {
    final active = OrdersScope.of(context).active;
    if (active.isEmpty) return const SizedBox(height: 8);
    final Order order = active.first;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: FoodTheme(
        seed: order.restaurant.seedColor,
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final scheme = theme.colorScheme;
            return Material(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TrackingScreen(orderId: order.id),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.delivery_dining_rounded,
                            color: scheme.onPrimary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              order.status.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: scheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${order.minutesRemaining} min',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: scheme.onPrimary,
                            ),
                          ),
                          Icon(Icons.chevron_right, color: scheme.onPrimary),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: order.progress.clamp(0.02, 1),
                        child: Container(
                          height: 4,
                          color: scheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
