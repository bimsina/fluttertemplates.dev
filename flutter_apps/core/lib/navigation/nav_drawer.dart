import 'package:flutter/material.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    // Open the drawer on load so the preview shows it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldKey.currentState?.openDrawer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: const Text('Navigation Drawer')),
      drawer: NavigationDrawer(
        selectedIndex: _selected,
        onDestinationSelected: (i) {
          setState(() => _selected = i);
          Navigator.pop(context);
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 16, 16),
            child: Row(
              children: [
                const CircleAvatar(radius: 26, child: Text('AK')),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alex Kim',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('alex@acme.io',
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          const NavigationDrawerDestination(
              icon: Icon(Icons.home_outlined), label: Text('Home')),
          const NavigationDrawerDestination(
              icon: Icon(Icons.explore_outlined), label: Text('Explore')),
          const NavigationDrawerDestination(
              icon: Icon(Icons.bookmark_border), label: Text('Saved')),
          const NavigationDrawerDestination(
              icon: Icon(Icons.settings_outlined), label: Text('Settings')),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 28, 8),
            child: Divider(),
          ),
          const NavigationDrawerDestination(
              icon: Icon(Icons.logout), label: Text('Sign out')),
        ],
      ),
      body: Center(
        child: TextButton.icon(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu),
          label: const Text('Open the drawer'),
        ),
      ),
    );
  }
}
