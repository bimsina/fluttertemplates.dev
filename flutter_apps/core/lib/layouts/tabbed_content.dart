import 'package:flutter/material.dart';

class TabbedContent extends StatefulWidget {
  const TabbedContent({super.key});

  @override
  State<TabbedContent> createState() => _TabbedContentState();
}

class _TabbedContentState extends State<TabbedContent>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabbed Content'),
        bottom: TabBar(
          controller: _controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Details'),
            Tab(text: 'Settings'),
            Tab(text: 'Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          _ContentTab(
            icon: Icons.dashboard,
            text: 'Overview content with summary and stats.',
          ),
          _ContentTab(
            icon: Icons.info_outline,
            text: 'Details tab with more information.',
          ),
          _ContentTab(
            icon: Icons.settings,
            text: 'Settings and configuration options.',
          ),
          _ContentTab(
            icon: Icons.timeline,
            text: 'Activity log and recent events.',
          ),
        ],
      ),
    );
  }
}

class _ContentTab extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContentTab({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
