import 'package:flutter/material.dart';

import '../models/formatting.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../state/app_scope.dart';
import '../widgets/common.dart';
import '../widgets/dish_art.dart';
import '../widgets/food_theme.dart';
import '../widgets/layout.dart';
import '../widgets/ticket.dart';
import 'cart_screen.dart';
import 'item_screen.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  static const _chipBarHeight = 56.0;
  static const _maxWidth = 860.0;

  final _scroll = ScrollController();
  final _activeSection = ValueNotifier<int>(0);
  late final _sectionKeys = List.generate(
    widget.restaurant.sections.length,
    (_) => GlobalKey(),
  );

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_syncActiveSection);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _activeSection.dispose();
    super.dispose();
  }

  double get _pinnedHeight =>
      MediaQuery.paddingOf(context).top + kToolbarHeight + _chipBarHeight;

  /// Distance from the top of this screen to the top of a section.
  double? _sectionTop(int index) {
    final screen = context.findRenderObject() as RenderBox?;
    final section =
        _sectionKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (screen == null || section == null) return null;
    return section.localToGlobal(Offset.zero, ancestor: screen).dy;
  }

  void _syncActiveSection() {
    var active = 0;
    for (var i = 0; i < _sectionKeys.length; i++) {
      final top = _sectionTop(i);
      if (top != null && top <= _pinnedHeight + 24) active = i;
    }
    _activeSection.value = active;
  }

  void _jumpToSection(int index) {
    final top = _sectionTop(index);
    if (top == null) return;
    final target = _scroll.offset + top - _pinnedHeight;
    _scroll.animateTo(
      target.clamp(0, _scroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    return FoodTheme(
      seed: restaurant.seedColor,
      child: Builder(
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          return Scaffold(
            body: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final gutter = centeredGutter(
                      constraints.maxWidth,
                      _maxWidth,
                    );
                    return CustomScrollView(
                      controller: _scroll,
                      slivers: [
                        _Banner(restaurant: restaurant, scheme: scheme),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 8),
                          sliver: SliverToBoxAdapter(
                            child: _Facts(restaurant: restaurant),
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SectionChips(
                            sections: restaurant.sections,
                            active: _activeSection,
                            gutter: gutter,
                            height: _chipBarHeight,
                            onSelected: _jumpToSection,
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(gutter, 4, gutter, 112),
                          // One box on purpose: every section stays laid out,
                          // so the chips can always measure where it is.
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (
                                  var i = 0;
                                  i < restaurant.sections.length;
                                  i++
                                )
                                  _SectionList(
                                    key: _sectionKeys[i],
                                    restaurant: restaurant,
                                    section: restaurant.sections[i],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _CartBar(restaurant: restaurant),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.restaurant, required this.scheme});

  final Restaurant restaurant;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 232,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        expandedTitleScale: 1.3,
        titlePadding: const EdgeInsetsDirectional.only(
          start: 56,
          end: 16,
          bottom: 15,
        ),
        title: Text(
          restaurant.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: scheme.onPrimaryContainer),
        ),
        background: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              right: -24,
              top: MediaQuery.paddingOf(context).top + 4,
              child: Hero(
                tag: 'restaurant-art-${restaurant.id}',
                child: DishArt(
                  kind: restaurant.kind,
                  size: 176,
                  scheme: scheme,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(restaurant.cuisine, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            Fact(
              icon: Icons.star_rounded,
              label:
                  '${restaurant.rating.toStringAsFixed(1)} '
                  '(${restaurant.reviewCount})',
              color: muted,
            ),
            Fact(
              icon: Icons.schedule_rounded,
              label: '${restaurant.etaMinutes} min',
              color: muted,
            ),
            Fact(
              icon: Icons.delivery_dining_rounded,
              label: restaurant.deliveryFeeCents == 0
                  ? 'Free delivery'
                  : '${formatMoney(restaurant.deliveryFeeCents)} delivery',
              color: muted,
            ),
            Fact(
              icon: Icons.shopping_basket_outlined,
              label: '${formatMoney(restaurant.minimumOrderCents)} minimum',
              color: muted,
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionChips extends SliverPersistentHeaderDelegate {
  _SectionChips({
    required this.sections,
    required this.active,
    required this.gutter,
    required this.height,
    required this.onSelected,
  });

  final List<MenuSection> sections;
  final ValueNotifier<int> active;
  final double gutter;
  final double height;
  final ValueChanged<int> onSelected;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ColoredBox(
      color: scheme.surface,
      child: ValueListenableBuilder<int>(
        valueListenable: active,
        builder: (context, activeIndex, _) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: gutter, vertical: 10),
          itemCount: sections.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final selected = index == activeIndex;
            return Material(
              color: selected ? scheme.primary : scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onSelected(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      sections[index].title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: selected ? scheme.onPrimary : scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SectionChips oldDelegate) =>
      oldDelegate.gutter != gutter || oldDelegate.sections != sections;
}

class _SectionList extends StatelessWidget {
  const _SectionList({
    super.key,
    required this.restaurant,
    required this.section,
  });

  final Restaurant restaurant;
  final MenuSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 10),
          child: Text(
            section.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 10.0;
            final columns = constraints.maxWidth >= wideBreakpoint ? 2 : 1;
            final tileWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final item in section.items)
                  SizedBox(
                    width: tileWidth,
                    child: _MenuItemTile(restaurant: restaurant, item: item),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({required this.restaurant, required this.item});

  final Restaurant restaurant;
  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final quantity = CartScope.of(context).quantityOf(item.id);
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => ItemScreen(restaurant: restaurant, item: item),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.popular)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          'Most ordered',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    Text(item.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatMoney(item.priceCents),
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox.square(
                dimension: 84,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    DishArt(kind: item.kind, size: 84),
                    if (quantity > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scheme.surfaceContainerLow,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '$quantity',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Slides up as soon as this restaurant has something in the cart.
class _CartBar extends StatelessWidget {
  const _CartBar({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cart = CartScope.of(context);
    final visible = !cart.isEmpty && cart.restaurant?.id == restaurant.id;
    final labelStyle = theme.textTheme.titleSmall?.copyWith(
      color: scheme.onPrimary,
    );
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 1.5),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ContentWidth(
              child: Material(
                color: scheme.primary,
                elevation: 4,
                shadowColor: scheme.shadow,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const CartScreen()),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    child: Row(
                      children: [
                        Text(
                          pluralize(cart.itemCount, 'item'),
                          style: labelStyle,
                        ),
                        Expanded(
                          child: Text(
                            'View cart',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: labelStyle,
                          ),
                        ),
                        AnimatedMoney(
                          cents: cart.subtotalCents,
                          style: labelStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
