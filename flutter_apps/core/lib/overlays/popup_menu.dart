import 'package:flutter/material.dart';

class PopupMenuPage extends StatefulWidget {
  const PopupMenuPage({super.key});

  @override
  State<PopupMenuPage> createState() => _PopupMenuPageState();
}

class _PopupMenuPageState extends State<PopupMenuPage> {
  var _lastChoice = 'Nothing yet';

  void _choose(String choice) => setState(() => _lastChoice = choice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popup Menu'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _choose,
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'Edit', child: Text('Edit')),
              const PopupMenuItem(value: 'Share', child: Text('Share')),
              const PopupMenuItem(value: 'Delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Last choice: $_lastChoice'),
              const SizedBox(height: 24),
              PopupMenuButton<String>(
                onSelected: _choose,
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'Option A',
                    child: Text('Option A'),
                  ),
                  const PopupMenuItem(
                    value: 'Option B',
                    child: Text('Option B'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'Option C',
                    child: Text('Option C'),
                  ),
                ],
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('PopupMenuButton'),
                ),
              ),
              const SizedBox(height: 24),
              MenuAnchor(
                builder: (ctx, controller, child) => FilledButton(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: const Text('MenuAnchor'),
                ),
                menuChildren: [
                  MenuItemButton(
                    onPressed: () => _choose('Item 1'),
                    child: const Text('Item 1'),
                  ),
                  MenuItemButton(
                    onPressed: () => _choose('Item 2'),
                    child: const Text('Item 2'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onLongPress: _showContextMenu,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Long-press for context menu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showContextMenu() async {
    final choice = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 200, 100, 200),
      items: [
        const PopupMenuItem(value: 'Copy', child: Text('Copy')),
        const PopupMenuItem(value: 'Paste', child: Text('Paste')),
      ],
    );
    if (choice != null && mounted) _choose(choice);
  }
}
