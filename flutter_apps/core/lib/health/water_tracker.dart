import 'package:flutter/material.dart';

const _goal = 8;
const _current = 5;

class WaterTracker extends StatelessWidget {
  const WaterTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Water Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Today\'s Goal: $_goal glasses',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_goal, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < _current ? Icons.water_drop : Icons.water_drop_outlined,
                    size: 40,
                    color: i < _current ? Colors.blue : Colors.grey.shade400,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text('$_current / $_goal glasses',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            LinearProgressIndicator(
              value: _current / _goal,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add Glass'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
