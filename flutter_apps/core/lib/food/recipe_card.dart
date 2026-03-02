import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              color: Colors.orange.shade200,
              child: Center(
                child: Icon(Icons.restaurant_menu, size: 80, color: Colors.orange.shade700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Classic Margherita Pizza',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      Text(' 45 min', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 16),
                      Icon(Icons.restaurant, size: 16, color: Colors.grey[600]),
                      Text(' 4 servings', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
                  ...['Pizza dough', 'Tomato sauce', 'Fresh mozzarella', 'Basil', 'Olive oil']
                      .map((i) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.circle, size: 8),
                            title: Text(i),
                          )),
                  const SizedBox(height: 8),
                  Text('Instructions', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '1. Preheat oven to 475°F. Stretch dough on a floured surface.\n'
                    '2. Spread tomato sauce, add mozzarella slices.\n'
                    '3. Bake 12-15 min until crust is golden.\n'
                    '4. Top with basil and drizzle olive oil.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
