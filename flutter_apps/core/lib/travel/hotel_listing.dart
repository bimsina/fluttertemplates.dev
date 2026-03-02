import 'package:flutter/material.dart';

const _hotels = [
  {'name': 'Grand Plaza', 'location': 'Downtown', 'price': '\$189', 'rating': 4.8},
  {'name': 'Seaside Resort', 'location': 'Beach', 'price': '\$249', 'rating': 4.9},
  {'name': 'Mountain View', 'location': 'Hill Station', 'price': '\$129', 'rating': 4.5},
];

class HotelListing extends StatelessWidget {
  const HotelListing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotels'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _hotels.length,
        itemBuilder: (context, i) {
          final h = _hotels[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.primaries[i].withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              title: Text(h['name'] as String),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h['location'] as String),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber[700]),
                      Text(' ${h['rating']}'),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    h['price'] as String,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('/ night', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
