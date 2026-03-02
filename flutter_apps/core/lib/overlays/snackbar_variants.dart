import 'package:flutter/material.dart';

class SnackbarVariants extends StatelessWidget {
  const SnackbarVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Snackbar Variants')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Simple snackbar')),
            ),
            child: const Text('Simple'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Action snackbar'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {},
                ),
              ),
            ),
            child: const Text('With Action'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(child: Text('Success with icon')),
                  ],
                ),
                backgroundColor: Colors.green,
              ),
            ),
            child: const Text('With Icon'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Error message'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
            child: const Text('Error Style'),
          ),
        ],
      ),
    );
  }
}
