import 'package:flutter/material.dart';

class PageTransitions extends StatelessWidget {
  const PageTransitions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Transitions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TransitionButton(
            label: 'Fade',
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const _DemoPage(title: 'Fade'),
                transitionsBuilder: (_, animation, _, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            ),
          ),
          _TransitionButton(
            label: 'Slide',
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const _DemoPage(title: 'Slide'),
                transitionsBuilder: (_, animation, _, child) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
            ),
          ),
          _TransitionButton(
            label: 'Scale',
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const _DemoPage(title: 'Scale'),
                transitionsBuilder: (_, animation, _, child) =>
                    ScaleTransition(scale: animation, child: child),
              ),
            ),
          ),
          _TransitionButton(
            label: 'Rotation',
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const _DemoPage(title: 'Rotation'),
                transitionsBuilder: (_, animation, _, child) =>
                    RotationTransition(turns: animation, child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransitionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TransitionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FilledButton(onPressed: onTap, child: Text(label)),
    );
  }
}

class _DemoPage extends StatelessWidget {
  final String title;

  const _DemoPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
