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
                ElevatedButton(onPressed: () {}, child: const Text('Default')),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('With Icon'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const SizedBox(
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
                FilledButton(onPressed: () {}, child: const Text('Default')),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('With Icon'),
                ),
                FilledButton(
                  onPressed: () {},
                  child: const SizedBox(
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
                OutlinedButton(onPressed: () {}, child: const Text('Default')),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('With Icon'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const SizedBox(
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
                TextButton(onPressed: () {}, child: const Text('Default')),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('With Icon'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const SizedBox(
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
                IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                IconButton.filled(
                  onPressed: () {},
                  icon: const Icon(Icons.delete),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                const IconButton(onPressed: null, icon: Icon(Icons.settings)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
