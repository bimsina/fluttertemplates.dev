import 'package:flutter/material.dart';

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        actions: [
          IconButton(icon: const Icon(Icons.grid_view), onPressed: () {}),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: 12,
        itemBuilder: (context, i) {
          return Container(
            color: Colors.primaries[i % Colors.primaries.length].withValues(alpha: 0.5),
            child: Icon(
              Icons.photo,
              color: Colors.white.withValues(alpha: 0.8),
              size: 32,
            ),
          );
        },
      ),
    );
  }
}
