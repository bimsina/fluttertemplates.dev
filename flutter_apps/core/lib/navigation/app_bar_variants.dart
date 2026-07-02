import 'package:flutter/material.dart';

class AppBarVariants extends StatelessWidget {
  const AppBarVariants({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('App Bar Variants')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label(context, 'Standard'),
          _bar(
            context,
            child: Row(
              children: [
                const Icon(Icons.menu),
                const SizedBox(width: 16),
                const Text('Inbox',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(Icons.search),
                const SizedBox(width: 16),
                const Icon(Icons.more_vert),
              ],
            ),
          ),
          _label(context, 'Search'),
          _bar(
            context,
            child: Row(
              children: [
                const Icon(Icons.arrow_back),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            size: 18, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('Search mail',
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _label(context, 'Gradient'),
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [scheme.primary, scheme.tertiary]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: const [
                Icon(Icons.arrow_back, color: Colors.white),
                SizedBox(width: 16),
                Text('Profile',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                Spacer(),
                Icon(Icons.edit, color: Colors.white),
              ],
            ),
          ),
          _label(context, 'With tabs'),
          Container(
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Text('Team',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      Spacer(),
                      Icon(Icons.add, color: Colors.white),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _tab('Members', true, scheme),
                    _tab('Pending', false, scheme),
                    _tab('Archived', false, scheme),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String text, bool active, ColorScheme scheme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: active ? Colors.white : Colors.transparent, width: 3),
          ),
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: active ? Colors.white : Colors.white70)),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 0, 10),
      child: Text(text.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1,
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }

  Widget _bar(BuildContext context, {required Widget child}) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}
