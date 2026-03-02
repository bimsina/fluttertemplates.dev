import 'package:flutter/material.dart';

class OverlayDialogs extends StatelessWidget {
  const OverlayDialogs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialogs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Confirmation Dialog'),
            onTap: () => _showConfirmDialog(context),
          ),
          ListTile(
            title: const Text('Input Dialog'),
            onTap: () => _showInputDialog(context),
          ),
          ListTile(
            title: const Text('Multi-Choice Dialog'),
            onTap: () => _showMultiChoiceDialog(context),
          ),
          ListTile(
            title: const Text('Loading Dialog'),
            onTap: () => _showLoadingDialog(context),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showInputDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Your name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMultiChoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Option A'),
              onTap: () => Navigator.pop(ctx, 'A'),
            ),
            ListTile(
              title: const Text('Option B'),
              onTap: () => Navigator.pop(ctx, 'B'),
            ),
            ListTile(
              title: const Text('Option C'),
              onTap: () => Navigator.pop(ctx, 'C'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 24),
            Text('Loading...'),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) Navigator.pop(context);
    });
  }
}
