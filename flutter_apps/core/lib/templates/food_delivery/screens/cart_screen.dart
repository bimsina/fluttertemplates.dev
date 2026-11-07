import 'package:flutter/material.dart';

import '../models/cart_line.dart';
import '../models/formatting.dart';
import '../models/restaurant.dart';
import '../state/app_scope.dart';
import '../state/cart_controller.dart';
import '../widgets/common.dart';
import '../widgets/dish_art.dart';
import '../widgets/food_theme.dart';
import '../widgets/layout.dart';
import '../widgets/ticket.dart';
import 'checkout_screen.dart';
import 'item_screen.dart';
import 'restaurant_screen.dart';

/// The cart. Used both as a tab and as a pushed route from a menu.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _confirmClear(BuildContext context, CartController cart) async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty your cart?'),
        content: const Text('All items will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Empty cart'),
          ),
        ],
      ),
    );
    if (clear ?? false) cart.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final restaurant = cart.restaurant;
    if (restaurant == null || cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your cart')),
        body: EmptyState(
          title: 'Your cart is empty',
          message: 'Add something from a restaurant and it will show up here.',
          actionLabel: 'Browse restaurants',
          onAction: () {
            TabScope.read(context).value = TabScope.home;
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      );
    }

    return FoodTheme(
      seed: restaurant.seedColor,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your cart'),
          actions: [
            IconButton(
              tooltip: 'Empty cart',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmClear(context, cart),
            ),
          ],
        ),
        bottomNavigationBar: _CheckoutBar(cart: cart),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ContentWidth(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RestaurantRow(restaurant: restaurant),
                    const SizedBox(height: 10),
                    for (final (index, line) in cart.lines.indexed)
                      _LineRow(
                        key: ValueKey(line.id),
                        cart: cart,
                        restaurant: restaurant,
                        line: line,
                        index: index,
                      ),
                    const SizedBox(height: 10),
                    const _PromoField(),
                    const SizedBox(height: 18),
                    ReceiptCard(
                      prices: cart.prices,
                      promoLabel: cart.promo?.code,
                      showTip: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantRow extends StatelessWidget {
  const _RestaurantRow({required this.restaurant});

  final Restaurant restaurant;

  void _addMore(BuildContext context) {
    final navigator = Navigator.of(context);
    // Pushed from the menu: go back to it. In the tab: open the menu.
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => RestaurantScreen(restaurant: restaurant),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        DishArt(kind: restaurant.kind, size: 44),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            restaurant.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
        ),
        TextButton(
          onPressed: () => _addMore(context),
          child: const Text('Add more'),
        ),
      ],
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({
    super.key,
    required this.cart,
    required this.restaurant,
    required this.line,
    required this.index,
  });

  final CartController cart;
  final Restaurant restaurant;
  final CartLine line;
  final int index;

  void _remove(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    cart.remove(line.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${line.item.name} removed'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => cart.restore(restaurant, line, index),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey('dismiss-${line.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _remove(context),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
        ),
        child: Material(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                fullscreenDialog: true,
                builder: (_) => ItemScreen(
                  restaurant: restaurant,
                  item: line.item,
                  editing: line,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DishArt(kind: line.item.kind, size: 52),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.item.name,
                              style: theme.textTheme.titleSmall,
                            ),
                            if (line.selected.isNotEmpty)
                              Text(
                                line.optionsSummary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            if (line.note.isNotEmpty)
                              Text(
                                'Note: ${line.note}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      QuantityStepper(
                        compact: true,
                        min: 0,
                        quantity: line.quantity,
                        onChanged: (value) => value == 0
                            ? _remove(context)
                            : cart.setQuantity(line.id, value),
                      ),
                      const Spacer(),
                      AnimatedMoney(
                        cents: line.totalCents,
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
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

class _PromoField extends StatefulWidget {
  const _PromoField();

  @override
  State<_PromoField> createState() => _PromoFieldState();
}

class _PromoFieldState extends State<_PromoField> {
  final _controller = TextEditingController();
  bool _checking = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Enter a code');
      return;
    }
    final cart = CartScope.read(context);
    final repository = RepositoryScope.of(context);
    setState(() {
      _checking = true;
      _error = null;
    });
    final promo = await repository.redeemPromo(code);
    if (!mounted) return;
    setState(() {
      _checking = false;
      if (promo == null) _error = 'That code is not valid';
    });
    if (promo != null) {
      cart.applyPromo(promo);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cart = CartScope.of(context);
    final promo = cart.promo;

    if (promo != null) {
      return Container(
        padding: const EdgeInsets.only(left: 14),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_offer_rounded,
              size: 18,
              color: scheme.onPrimaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${promo.code}: ${promo.label}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Remove code',
              color: scheme.onPrimaryContainer,
              onPressed: cart.removePromo,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => _apply(),
            decoration: InputDecoration(
              hintText: 'Promo code, try WELCOME10',
              hintMaxLines: 1,
              errorText: _error,
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: _checking ? null : _apply,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(72, 48),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: _checking
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Apply'),
        ),
      ],
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final restaurant = cart.restaurant!;
    final missing = cart.shortOfMinimumCents;
    return BottomActionBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (missing > 0) ...[
            Text(
              'Add ${formatMoney(missing)} more to reach the '
              '${formatMoney(restaurant.minimumOrderCents)} minimum',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: cart.subtotalCents / restaurant.minimumOrderCents,
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),
            const SizedBox(height: 10),
          ],
          FilledButton(
            onPressed: missing > 0
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CheckoutScreen(),
                    ),
                  ),
            child: const Text('Go to checkout'),
          ),
        ],
      ),
    );
  }
}
