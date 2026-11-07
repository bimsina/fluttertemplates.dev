import 'package:flutter/material.dart';

class _Listing {
  final String title;
  final String price;
  final String location;
  final String category;
  final IconData icon;
  final Color color;
  const _Listing(this.title, this.price, this.location, this.category,
      this.icon, this.color);
}

class ListingsGrid extends StatefulWidget {
  const ListingsGrid({super.key});

  @override
  State<ListingsGrid> createState() => _ListingsGridState();
}

class _ListingsGridState extends State<ListingsGrid> {
  int _filter = 0;
  static const _filters = ['All', 'Furniture', 'Electronics', 'Bikes', 'Books'];
  final _faved = <String>{'Road bike'};

  static const _items = [
    _Listing('Vintage armchair', '\$120', '2 mi', 'Furniture', Icons.chair,
        Color(0xFF8D6E63)),
    _Listing('Road bike', '\$340', '5 mi', 'Bikes', Icons.pedal_bike,
        Color(0xFF42A5F5)),
    _Listing('Desk lamp', '\$28', '1 mi', 'Electronics', Icons.light,
        Color(0xFFFFB74D)),
    _Listing('Bookshelf', '\$75', '3 mi', 'Furniture', Icons.shelves,
        Color(0xFF66BB6A)),
    _Listing('Headphones', '\$90', '4 mi', 'Electronics', Icons.headphones,
        Color(0xFFBA68C8)),
    _Listing('Coffee table', '\$60', '6 mi', 'Furniture', Icons.table_bar,
        Color(0xFF26A69A)),
    _Listing('Paperback bundle', '\$15', '2 mi', 'Books', Icons.menu_book,
        Color(0xFFEF5350)),
  ];

  List<_Listing> get _visibleItems => _filter == 0
      ? _items
      : _items.where((it) => it.category == _filters[_filter]).toList();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [IconButton(tooltip: 'Search', onPressed: () => _showDemo(context, 'Search (demo)'), icon: const Icon(Icons.search))],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Center(
                child: ChoiceChip(
                  label: Text(_filters[i]),
                  selected: _filter == i,
                  onSelected: (_) => setState(() => _filter = i),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(12),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
              children: [
                for (final item in _visibleItems) _card(scheme, item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(ColorScheme scheme, _Listing it) {
    final faved = _faved.contains(it.title);
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: it.color.withValues(alpha: 0.2),
                    child: Icon(it.icon, size: 48, color: it.color),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: scheme.surface,
                    child: IconButton(
                      tooltip: faved ? 'Remove from favorites' : 'Add to favorites',
                      iconSize: 16,
                      padding: EdgeInsets.zero,
                      onPressed: () => setState(() =>
                          faved ? _faved.remove(it.title) : _faved.add(it.title)),
                      icon: Icon(
                          faved ? Icons.favorite : Icons.favorite_border,
                          color: faved ? scheme.error : scheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it.price,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(it.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(it.location,
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
