import 'package:flutter/material.dart';

class ProductSearch extends StatefulWidget {
  const ProductSearch({super.key});

  @override
  State<ProductSearch> createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearch> {
  var _priceRange = 'Any';
  var _category = 'All';
  var _minRating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Price'),
                selected: _priceRange != 'Any',
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Category'),
                selected: _category != 'All',
                onSelected: (_) {},
              ),
              FilterChip(
                label: Text(
                  'Rating ${_minRating > 0 ? ">= $_minRating" : "Any"}',
                ),
                selected: _minRating > 0,
                onSelected: (_) {},
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
          ...List.generate(
            3,
            (i) => ListTile(
              leading: Container(
                width: 50,
                height: 50,
                color: Colors.primaries[i].withValues(alpha: 0.3),
              ),
              title: Text('Product ${i + 1}'),
              subtitle: Text('\$${(i + 1) * 15}.99'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: Colors.amber[700]),
                  Text(' 4.$i'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
