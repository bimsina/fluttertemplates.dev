import 'package:flutter/material.dart';

class BoardingPass extends StatelessWidget {
  const BoardingPass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boarding Pass')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AA 1234',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Chip(label: Text('BOARDING')),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('JFK', style: Theme.of(context).textTheme.headlineMedium),
                        Text('New York'),
                      ],
                    ),
                    Icon(Icons.flight, color: Theme.of(context).colorScheme.primary),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('LAX', style: Theme.of(context).textTheme.headlineMedium),
                        Text('Los Angeles'),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                _infoRow('Passenger', 'John Doe'),
                _infoRow('Seat', '12A'),
                _infoRow('Gate', 'B14'),
                _infoRow('Boarding', '10:45 AM'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(20, (i) => Container(
                    width: 3,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    color: i.isEven ? Colors.black : Colors.transparent,
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }
}
