import 'package:flutter/material.dart';

const _goal = 8;

class WaterTracker extends StatefulWidget {
  const WaterTracker({super.key});

  @override
  State<WaterTracker> createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> {
  var _current = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Water Tracker')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Today\'s Goal: $_goal glasses',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
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
                onPressed: _current < _goal
                    ? () => setState(() => _current++)
                    : null,
                icon: const Icon(Icons.add),
                label: const Text('Add Glass'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
