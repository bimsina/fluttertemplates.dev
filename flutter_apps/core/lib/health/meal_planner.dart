import 'package:flutter/material.dart';

const _meals = [
  {'day': 'Mon', 'breakfast': 'Oatmeal', 'lunch': 'Salad', 'dinner': 'Chicken'},
  {'day': 'Tue', 'breakfast': 'Eggs', 'lunch': 'Sandwich', 'dinner': 'Pasta'},
  {'day': 'Wed', 'breakfast': 'Smoothie', 'lunch': 'Soup', 'dinner': 'Fish'},
  {'day': 'Thu', 'breakfast': 'Toast', 'lunch': 'Wrap', 'dinner': 'Beef'},
  {'day': 'Fri', 'breakfast': 'Yogurt', 'lunch': 'Burrito', 'dinner': 'Pizza'},
];

class MealPlanner extends StatelessWidget {
  const MealPlanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Planner')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surfaceContainerHighest),
              columns: const [
                DataColumn(label: Text('Day')),
                DataColumn(label: Text('Breakfast')),
                DataColumn(label: Text('Lunch')),
                DataColumn(label: Text('Dinner')),
              ],
              rows: _meals
                  .map((m) => DataRow(
                        cells: [
                          DataCell(Text(m['day'] as String)),
                          DataCell(Text(m['breakfast'] as String)),
                          DataCell(Text(m['lunch'] as String)),
                          DataCell(Text(m['dinner'] as String)),
                        ],
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add Day'),
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
          ),
        ],
      ),
    );
  }
}
