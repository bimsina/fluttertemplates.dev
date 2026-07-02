import 'package:flutter/material.dart';

class ListingDetail extends StatefulWidget {
  const ListingDetail({super.key});

  @override
  State<ListingDetail> createState() => _ListingDetailState();
}

class _ListingDetailState extends State<ListingDetail> {
  final _pageController = PageController();
  int _page = 0;

  static const _colors = [
    Color(0xFF8D6E63),
    Color(0xFFA1887F),
    Color(0xFFBCAAA4),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.favorite_border)),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 260,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    for (final c in _colors)
                      Container(
                        color: c.withValues(alpha: 0.3),
                        child: Icon(Icons.chair,
                            size: 96, color: c),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_colors.length, (i) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _page
                              ? scheme.primary
                              : scheme.onSurfaceVariant
                                  .withValues(alpha: 0.4),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\$120',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Vintage armchair',
                    style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('Listed 2 days ago · Marylebone',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 20),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Text('EP')),
                    title: const Text('Elena Petrova'),
                    subtitle: const Text('4.9 ★ · 48 sales'),
                    trailing: OutlinedButton(
                        onPressed: () {}, child: const Text('View')),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Description',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  'A well-loved mid-century armchair in solid oak with newly reupholstered cushions. Minor wear on the armrests. Pick-up only.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        color: scheme.surface,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Message')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                  onPressed: () {}, child: const Text('Buy now')),
            ),
          ],
        ),
      ),
    );
  }
}
