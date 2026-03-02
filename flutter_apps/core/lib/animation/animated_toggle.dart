import 'package:flutter/material.dart';

class AnimatedToggle extends StatefulWidget {
  const AnimatedToggle({super.key});

  @override
  State<AnimatedToggle> createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<AnimatedToggle> {
  var _on = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated Toggle')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => _on = !_on),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 36,
                decoration: BoxDecoration(
                  color: _on
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: _on ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _on ? Icons.check : Icons.close,
                        key: ValueKey(_on),
                        size: 18,
                        color: _on
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _on ? 'On' : 'Off',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
