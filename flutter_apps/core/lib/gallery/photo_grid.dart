import 'package:flutter/material.dart';

class PhotoGrid extends StatefulWidget {
  const PhotoGrid({super.key});

  @override
  State<PhotoGrid> createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  var _columns = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        actions: [
          IconButton(tooltip: 'Change layout', icon: const Icon(Icons.grid_view), onPressed: () => setState(() => _columns = _columns == 3 ? 2 : 3)),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _columns,
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
