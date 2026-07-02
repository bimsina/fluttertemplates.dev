import 'package:flutter/material.dart';

class EventDetail extends StatelessWidget {
  const EventDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF7E57C2), scheme.primary],
                  ),
                ),
                child: const Center(
                    child: Icon(Icons.music_note,
                        size: 80, color: Colors.white38)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Indie Nights Live',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _row(scheme, Icons.calendar_today, 'Friday, Jul 12 · 8:00 PM'),
                  _row(scheme, Icons.location_on_outlined,
                      'The Warehouse, 24 Dock Rd'),
                  _row(scheme, Icons.confirmation_number_outlined,
                      'From \$25 · 320 going'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hosted by Lumen Collective',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('Organizer',
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant)),
                        ],
                      ),
                      const Spacer(),
                      OutlinedButton(
                          onPressed: () {}, child: const Text('Follow')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('About',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'An intimate evening of live indie music featuring three local bands, a rooftop bar, and food trucks. Doors open at 7 PM.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        color: scheme.surface,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('From', style: TextStyle(color: scheme.onSurfaceVariant)),
                const Text('\$25',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 52,
                child: FilledButton(
                    onPressed: () {}, child: const Text('Get tickets')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(ColorScheme scheme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}
