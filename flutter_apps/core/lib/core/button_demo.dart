import 'package:flutter/material.dart';

class ButtonDemo extends StatelessWidget {
  const ButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Button Components')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Elevated Buttons',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(onPressed: () => _showDemo(context, 'Elevated button (demo)'), child: const Text('Default')),
                ElevatedButton.icon(
                  onPressed: () => _showDemo(context, 'Elevated button with icon (demo)'),
                  icon: const Icon(Icons.add),
                  label: const Text('With Icon'),
                ),
                const ElevatedButton(
                  onPressed: null,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                const ElevatedButton(onPressed: null, child: Text('Disabled')),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Filled Buttons',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(onPressed: () => _showDemo(context, 'Filled button (demo)'), child: const Text('Default')),
                FilledButton.icon(
                  onPressed: () => _showDemo(context, 'Filled button with icon (demo)'),
                  icon: const Icon(Icons.add),
                  label: const Text('With Icon'),
                ),
                const FilledButton(
                  onPressed: null,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                const FilledButton(onPressed: null, child: Text('Disabled')),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Outlined Buttons',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(onPressed: () => _showDemo(context, 'Outlined button (demo)'), child: const Text('Default')),
                OutlinedButton.icon(
                  onPressed: () => _showDemo(context, 'Outlined button with icon (demo)'),
                  icon: const Icon(Icons.add),
                  label: const Text('With Icon'),
                ),
                const OutlinedButton(
                  onPressed: null,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                const OutlinedButton(onPressed: null, child: Text('Disabled')),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Text Buttons',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(onPressed: () => _showDemo(context, 'Text button (demo)'), child: const Text('Default')),
                TextButton.icon(
                  onPressed: () => _showDemo(context, 'Text button with icon (demo)'),
                  icon: const Icon(Icons.add),
                  label: const Text('With Icon'),
                ),
                const TextButton(
                  onPressed: null,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                const TextButton(onPressed: null, child: Text('Disabled')),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Icon Buttons',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                IconButton(tooltip: 'Add', onPressed: () => _showDemo(context, 'Icon button (demo)'), icon: const Icon(Icons.add)),
                IconButton.filled(
                  tooltip: 'Delete',
                  onPressed: () => _showDemo(context, 'Filled icon button (demo)'),
                  icon: const Icon(Icons.delete),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red,
                  ),
                ),
                const IconButton(
                  tooltip: 'Loading',
                  onPressed: null,
                  icon: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                const IconButton(tooltip: 'Settings', onPressed: null, icon: Icon(Icons.settings)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
