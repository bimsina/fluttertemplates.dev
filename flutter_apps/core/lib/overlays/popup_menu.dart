import 'package:flutter/material.dart';

class PopupMenuPage extends StatelessWidget {
  const PopupMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popup Menu'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (_) {},
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'share', child: Text('Share')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PopupMenuButton<String>(
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('PopupMenuButton'),
              ),
              onSelected: (_) {},
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'a', child: Text('Option A')),
                const PopupMenuItem(value: 'b', child: Text('Option B')),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'c', child: Text('Option C')),
              ],
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
                  onPressed: () {},
                  child: const Text('Item 1'),
                ),
                MenuItemButton(
                  onPressed: () {},
                  child: const Text('Item 2'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onLongPress: () => _showContextMenu(context),
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
    );
  }

  void _showContextMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 200, 100, 200),
      items: [
        const PopupMenuItem(value: 'copy', child: Text('Copy')),
        const PopupMenuItem(value: 'paste', child: Text('Paste')),
      ],
    );
  }
}
