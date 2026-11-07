import 'package:flutter/material.dart';

class ProductDetail extends StatefulWidget {
  /// Called with the chosen size and color index. Without it the demo shows
  /// a SnackBar and counts adds itself.
  final void Function(String size, int colorIndex)? onAddToCart;

  /// The host's cart size for the badge. With [onAddToCart] but no count the
  /// badge stays hidden, since only the host knows what the cart holds.
  final int? cartCount;

  const ProductDetail({super.key, this.onAddToCart, this.cartCount});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  var _size = 'M';
  var _color = 0;
  var _inCart = 0;

  void _addToCart() {
    final onAddToCart = widget.onAddToCart;
    if (onAddToCart != null) {
      onAddToCart(_size, _color);
      return;
    }
    setState(() => _inCart++);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
          SnackBar(content: Text('Added size $_size to cart (demo)')));
  }

  @override
  Widget build(BuildContext context) {
    final count =
        widget.cartCount ?? (widget.onAddToCart == null ? _inCart : null);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Semantics(
                  label: count == null ? 'Cart' : '$count in cart',
                  child: Badge.count(
                    count: count ?? 0,
                    isLabelVisible: (count ?? 0) > 0,
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.blue.withValues(alpha: 0.3),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Name',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('\$99.99',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('Size', style: Theme.of(context).textTheme.titleSmall),
                  Wrap(
                    spacing: 8,
                    children: ['S', 'M', 'L', 'XL']
                        .map((s) => ChoiceChip(
                              label: Text(s),
                              selected: _size == s,
                              onSelected: (_) => setState(() => _size = s),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Color', style: Theme.of(context).textTheme.titleSmall),
                  Wrap(
                    spacing: 8,
                    children: List.generate(
                      4,
                      (i) => ChoiceChip(
                        label: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.primaries[i % Colors.primaries.length],
                        ),
                        selected: _color == i,
                        onSelected: (_) => setState(() => _color = i),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _addToCart,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Add to Cart'),
            ),
          ),
        ),
      ),
    );
  }
}
