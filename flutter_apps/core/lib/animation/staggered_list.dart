import 'package:flutter/material.dart';

const _items = ['First', 'Second', 'Third', 'Fourth', 'Fifth', 'Sixth'];

class StaggeredList extends StatefulWidget {
  const StaggeredList({super.key});

  @override
  State<StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<StaggeredList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staggered List')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final delay = index * 0.1;
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final anim = CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  delay.clamp(0.0, 0.9),
                  (delay + 0.2).clamp(0.0, 1.0),
                  curve: Curves.easeOut,
                ),
              );
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(_items[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
