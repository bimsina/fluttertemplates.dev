import 'dart:math';

import 'package:flutter/material.dart';

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({super.key});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = _controller.drive(CurveTween(curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Shimmer Loading')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(
          5,
          (i) => _ShimmerCard(
            animation: _animation,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final Animation<double> animation;
  final bool isDark;

  const _ShimmerCard({
    required this.animation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(
              width: double.infinity,
              height: 120,
              animation: animation,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _ShimmerBox(
              width: 200,
              height: 16,
              animation: animation,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _ShimmerBox(
              width: 150,
              height: 14,
              animation: animation,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  static const _bandWidth = 240.0;

  final double width;
  final double height;
  final Animation<double> animation;
  final bool isDark;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.animation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[600]! : Colors.grey[100]!;

    // The band is placed in pixels from the screen width. Every box shares a
    // left edge, so one band crosses them all at the same speed.
    final travel = MediaQuery.sizeOf(context).width + _bandWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = min(width, constraints.maxWidth);
        // Converts a pixel offset within the box to an Alignment x value.
        double alignX(double pixels) => pixels / boxWidth * 2 - 1;

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final bandStart = animation.value * travel - _bandWidth;
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  begin: Alignment(alignX(bandStart), 0),
                  end: Alignment(alignX(bandStart + _bandWidth), 0),
                  colors: [baseColor, highlightColor, baseColor],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
