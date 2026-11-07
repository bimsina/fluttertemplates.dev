import 'package:flutter/material.dart';

class CollapsingAppBar extends StatefulWidget {
  const CollapsingAppBar({super.key});

  @override
  State<CollapsingAppBar> createState() => _CollapsingAppBarState();
}

class _CollapsingAppBarState extends State<CollapsingAppBar> {
  var _favorite = false;

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
                  tooltip:
                      _favorite ? 'Remove from favorites' : 'Add to favorites',
                  isSelected: _favorite,
                  onPressed: () => setState(() => _favorite = !_favorite),
                  icon: const Icon(Icons.favorite_border),
                  selectedIcon: const Icon(Icons.favorite)),
              IconButton(
                  tooltip: 'Share',
                  onPressed: () => _showDemo(context, 'Share (demo)'), icon: const Icon(Icons.share)),
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

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
