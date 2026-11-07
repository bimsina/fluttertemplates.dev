import 'package:flutter/material.dart';

enum _Sort {
  relevance('Relevance'),
  priceLow('Price: low to high'),
  priceHigh('Price: high to low'),
  rating('Top rated');

  const _Sort(this.label);
  final String label;
}

class _Stay {
  const _Stay(this.name, this.type, this.price, this.rating, this.wifi);

  final String name;
  final String type;
  final int price;
  final double rating;
  final bool wifi;
}

const _types = ['Apartment', 'House', 'Cabin', 'Hotel'];
const _minPrice = 40.0;
const _maxPrice = 400.0;

const _stays = [
  _Stay('Harbour View Loft', 'Apartment', 145, 4.8, true),
  _Stay('Old Town Studio', 'Apartment', 82, 4.3, true),
  _Stay('Birchwood Cabin', 'Cabin', 118, 4.9, false),
  _Stay('Lakeside Retreat', 'Cabin', 210, 4.6, true),
  _Stay('The Meridian', 'Hotel', 265, 4.5, true),
  _Stay('Station Inn', 'Hotel', 64, 3.7, true),
  _Stay('Garden Row House', 'House', 190, 4.4, true),
  _Stay('Cliffside Villa', 'House', 385, 4.9, true),
  _Stay('Canal Flat', 'Apartment', 99, 4.0, false),
  _Stay('Pine Ridge Lodge', 'Cabin', 160, 4.2, false),
];

/// Immutable, so the sheet can edit a draft and discard it on dismiss.
class _Filters {
  const _Filters({
    this.price = const RangeValues(_minPrice, _maxPrice),
    this.types = const {},
    this.minRating = 0,
    this.wifiOnly = false,
    this.sort = _Sort.relevance,
  });

  final RangeValues price;
  final Set<String> types;
  final double minRating;
  final bool wifiOnly;
  final _Sort sort;

  bool get hasCustomPrice =>
      price.start > _minPrice || price.end < _maxPrice;

  /// How many filters are on. Sorting narrows nothing, so it does not count.
  int get activeCount =>
      (hasCustomPrice ? 1 : 0) +
      types.length +
      (minRating > 0 ? 1 : 0) +
      (wifiOnly ? 1 : 0);

  _Filters copyWith({
    RangeValues? price,
    Set<String>? types,
    double? minRating,
    bool? wifiOnly,
    _Sort? sort,
  }) =>
      _Filters(
        price: price ?? this.price,
        types: types ?? this.types,
        minRating: minRating ?? this.minRating,
        wifiOnly: wifiOnly ?? this.wifiOnly,
        sort: sort ?? this.sort,
      );

  List<_Stay> apply(List<_Stay> stays) {
    final result = stays.where((s) {
      return s.price >= price.start &&
          s.price <= price.end &&
          (types.isEmpty || types.contains(s.type)) &&
          s.rating >= minRating &&
          (!wifiOnly || s.wifi);
    }).toList();
    switch (sort) {
      case _Sort.relevance:
        break;
      case _Sort.priceLow:
        result.sort((a, b) => a.price.compareTo(b.price));
      case _Sort.priceHigh:
        result.sort((a, b) => b.price.compareTo(a.price));
      case _Sort.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return result;
  }
}

class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({super.key});

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  var _filters = const _Filters();

  Future<void> _openSheet() async {
    final result = await showModalBottomSheet<_Filters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _FilterSheet(initial: _filters),
    );
    if (result != null) setState(() => _filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final results = _filters.apply(_stays);
    final f = _filters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stays'),
        actions: [
          IconButton(
            tooltip: 'Filters',
            onPressed: _openSheet,
            icon: Badge(
              isLabelVisible: f.activeCount > 0,
              label: Text('${f.activeCount}'),
              child: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (f.activeCount > 0)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (f.hasCustomPrice)
                    _AppliedChip(
                      label:
                          '\$${f.price.start.round()}–\$${f.price.end.round()}',
                      onRemove: () => setState(() {
                        _filters = f.copyWith(
                          price: const RangeValues(_minPrice, _maxPrice),
                        );
                      }),
                    ),
                  for (final type in f.types)
                    _AppliedChip(
                      label: type,
                      onRemove: () => setState(() {
                        _filters = f.copyWith(types: {...f.types}..remove(type));
                      }),
                    ),
                  if (f.minRating > 0)
                    _AppliedChip(
                      label: '${f.minRating}+ rating',
                      onRemove: () => setState(() {
                        _filters = f.copyWith(minRating: 0);
                      }),
                    ),
                  if (f.wifiOnly)
                    _AppliedChip(
                      label: 'Wi-Fi',
                      onRemove: () => setState(() {
                        _filters = f.copyWith(wifiOnly: false);
                      }),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              '${results.length} stays · ${f.sort.label}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No stays match these filters',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() {
                            _filters = _Filters(sort: f.sort);
                          }),
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) =>
                        _StayTile(stay: results[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AppliedChip extends StatelessWidget {
  const _AppliedChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: InputChip(
          label: Text(label),
          visualDensity: VisualDensity.compact,
          onDeleted: onRemove,
        ),
      ),
    );
  }
}

class _StayTile extends StatelessWidget {
  const _StayTile({required this.stay});

  final _Stay stay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
        child: Icon(switch (stay.type) {
          'Cabin' => Icons.cabin_outlined,
          'Hotel' => Icons.hotel_outlined,
          'House' => Icons.house_outlined,
          _ => Icons.apartment_outlined,
        }),
      ),
      title: Text(stay.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${stay.type} · ${stay.rating.toStringAsFixed(1)}'
        '${stay.wifi ? ' · Wi-Fi' : ''}',
      ),
      trailing: Text(
        '\$${stay.price}',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});

  final _Filters initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late var _draft = widget.initial;

  void _toggleType(String type) {
    final types = {..._draft.types};
    if (!types.remove(type)) types.add(type);
    setState(() => _draft = _draft.copyWith(types: types));
  }

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matches = _draft.apply(_stays).length;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 1,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Filters', style: theme.textTheme.titleLarge),
                ),
                TextButton(
                  onPressed: _draft.activeCount == 0 &&
                          _draft.sort == _Sort.relevance
                      ? null
                      : () => setState(() => _draft = const _Filters()),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                _heading(
                  'Price per night: \$${_draft.price.start.round()} – '
                  '\$${_draft.price.end.round()}',
                ),
                RangeSlider(
                  min: _minPrice,
                  max: _maxPrice,
                  divisions: 36,
                  values: _draft.price,
                  labels: RangeLabels(
                    '\$${_draft.price.start.round()}',
                    '\$${_draft.price.end.round()}',
                  ),
                  onChanged: (v) =>
                      setState(() => _draft = _draft.copyWith(price: v)),
                ),
                _heading('Property type'),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final type in _types)
                      FilterChip(
                        label: Text(type),
                        selected: _draft.types.contains(type),
                        onSelected: (_) => _toggleType(type),
                      ),
                  ],
                ),
                _heading('Minimum rating'),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final rating in const [0.0, 3.5, 4.0, 4.5])
                      ChoiceChip(
                        label: Text(rating == 0 ? 'Any' : '$rating+'),
                        showCheckmark: false,
                        selected: _draft.minRating == rating,
                        onSelected: (_) => setState(() {
                          _draft = _draft.copyWith(minRating: rating);
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Wi-Fi included'),
                  value: _draft.wifiOnly,
                  onChanged: (v) =>
                      setState(() => _draft = _draft.copyWith(wifiOnly: v)),
                ),
                _heading('Sort by'),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final sort in _Sort.values)
                      ChoiceChip(
                        label: Text(sort.label),
                        showCheckmark: false,
                        selected: _draft.sort == sort,
                        onSelected: (_) => setState(() {
                          _draft = _draft.copyWith(sort: sort);
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, _draft),
                  child: Text(
                    matches == 0 ? 'No matches' : 'Show $matches stays',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
