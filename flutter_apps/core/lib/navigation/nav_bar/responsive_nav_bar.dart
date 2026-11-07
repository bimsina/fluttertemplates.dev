import 'package:flutter/material.dart';

class ResponsiveNavBarPage extends StatefulWidget {
  const ResponsiveNavBarPage({super.key});

  @override
  State<ResponsiveNavBarPage> createState() => _ResponsiveNavBarPageState();
}

class _ResponsiveNavBarPageState extends State<ResponsiveNavBarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selected = _menuItems.first;

  // The links, the drawer and the profile menu all land here.
  void _select(String item) {
    setState(() => _selected = item);
    _showDemo(context, 'Open $item (demo)');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width > 800;

    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          leading: isLargeScreen
              ? null
              : IconButton(
                  tooltip: 'Open menu',
                  icon: const Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Logo",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLargeScreen) Expanded(child: _navBarItems()),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: _ProfileIcon(onSelected: _select)),
            ),
          ],
        ),
        drawer: isLargeScreen ? null : _drawer(),
        body: Center(child: Text(_selected)),
      ),
    );
  }

  Widget _drawer() => Drawer(
    child: ListView(
      children: _menuItems
          .map(
            (item) => ListTile(
              selected: item == _selected,
              selectedColor: Colors.green,
              onTap: () {
                _scaffoldKey.currentState?.closeDrawer();
                _select(item);
              },
              title: Text(item),
            ),
          )
          .toList(),
    ),
  );

  Widget _navBarItems() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: _menuItems
        .map(
          (item) => Semantics(
            selected: item == _selected,
            child: InkWell(
              onTap: () => _select(item),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 16,
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 18,
                    color: item == _selected ? Colors.green : null,
                  ),
                ),
              ),
            ),
          ),
        )
        .toList(),
  );
}

final List<String> _menuItems = <String>[
  'About',
  'Contact',
  'Settings',
  'Sign Out',
];

enum Menu { itemOne, itemTwo, itemThree }

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
      tooltip: 'Profile menu',
      icon: const Icon(Icons.person),
      offset: const Offset(0, 40),
      onSelected: (Menu item) => onSelected(switch (item) {
        Menu.itemOne => 'Account',
        Menu.itemTwo => 'Settings',
        Menu.itemThree => 'Sign Out',
      }),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
        const PopupMenuItem<Menu>(value: Menu.itemOne, child: Text('Account')),
        const PopupMenuItem<Menu>(value: Menu.itemTwo, child: Text('Settings')),
        const PopupMenuItem<Menu>(
          value: Menu.itemThree,
          child: Text('Sign Out'),
        ),
      ],
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
