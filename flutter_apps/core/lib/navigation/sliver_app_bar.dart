import 'package:flutter/material.dart';

class CollapsingAppBar extends StatelessWidget {
  const CollapsingAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Yosemite'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [scheme.primary, scheme.tertiary],
                  ),
                ),
                child: const Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.landscape,
                      size: 96, color: Colors.white24),
                ),
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border)),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.share)),
            ],
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text('Trail section ${i + 1}'),
                subtitle: const Text('Scroll up to collapse the header'),
              ),
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}
