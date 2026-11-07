import 'package:flutter/material.dart';

class _Product {
  final String title;
  final String category;
  final double price;
  final double rating;
  const _Product(this.title, this.category, this.price, this.rating);
}

const _products = [
  _Product('Wireless Earbuds', 'Electronics', 24.99, 4.2),
  _Product('Bluetooth Speaker', 'Electronics', 44.99, 4.6),
  _Product('Studio Headphones', 'Electronics', 129.99, 4.8),
  _Product('Canvas Tote', 'Fashion', 18.50, 3.9),
  _Product('Denim Jacket', 'Fashion', 64.00, 4.4),
  _Product('Ceramic Mug Set', 'Home', 22.00, 4.7),
  _Product('Linen Throw', 'Home', 39.00, 4.1),
  _Product('Floor Lamp', 'Home', 79.99, 3.6),
];

class ProductSearch extends StatefulWidget {
  const ProductSearch({super.key});

  @override
  State<ProductSearch> createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearch> {
  var _query = '';
  var _priceRange = 'Any';
  var _category = 'All';
  var _minRating = 0;

  bool _inPriceRange(double price) => switch (_priceRange) {
    '\$0-25' => price < 25,
    '\$25-50' => price >= 25 && price < 50,
    '\$50+' => price >= 50,
    _ => true,
  };

  List<_Product> get _results {
    final query = _query.trim().toLowerCase();
    return _products
        .where(
          (p) =>
              p.title.toLowerCase().contains(query) &&
              _inPriceRange(p.price) &&
              (_category == 'All' || p.category == _category) &&
              p.rating >= _minRating,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Each chip shows an active filter, and tapping it clears that filter.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: Text(_priceRange == 'Any' ? 'Price' : _priceRange),
                selected: _priceRange != 'Any',
                onSelected: _priceRange == 'Any'
                    ? null
                    : (_) => setState(() => _priceRange = 'Any'),
              ),
              FilterChip(
                label: Text(_category == 'All' ? 'Category' : _category),
                selected: _category != 'All',
                onSelected: _category == 'All'
                    ? null
                    : (_) => setState(() => _category = 'All'),
              ),
              FilterChip(
                label: Text(
                  'Rating ${_minRating > 0 ? ">= $_minRating" : "Any"}',
                ),
                selected: _minRating > 0,
                onSelected: _minRating == 0
                    ? null
                    : (_) => setState(() => _minRating = 0),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _priceRange,
            decoration: const InputDecoration(
              labelText: 'Price Range',
              border: OutlineInputBorder(),
            ),
            items: [
              'Any',
              '\$0-25',
              '\$25-50',
              '\$50+',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _priceRange = v ?? _priceRange),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: [
              'All',
              'Electronics',
              'Fashion',
              'Home',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 16),
          Text('Minimum rating', style: Theme.of(context).textTheme.titleSmall),
          Slider(
            value: _minRating.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            label: '$_minRating',
            onChanged: (v) => setState(() => _minRating = v.round()),
          ),
          const SizedBox(height: 16),
          if (results.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No products match your filters')),
            ),
          ...results.map(
            (p) => ListTile(
              leading: Container(
                width: 50,
                height: 50,
                color:
                    Colors.primaries[_products.indexOf(p) %
                            Colors.primaries.length]
                        .withValues(alpha: 0.3),
              ),
              title: Text(p.title),
              subtitle: Text('\$${p.price.toStringAsFixed(2)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: Colors.amber[700]),
                  Text(' ${p.rating}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
