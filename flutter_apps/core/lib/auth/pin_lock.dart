import 'package:flutter/material.dart';

class PinLock extends StatefulWidget {
  /// Called by 'Use biometrics'. Without it the demo shows a SnackBar.
  final VoidCallback? onUseBiometrics;

  const PinLock({super.key, this.onUseBiometrics});

  @override
  State<PinLock> createState() => _PinLockState();
}

class _PinLockState extends State<PinLock> {
  String _pin = '';
  bool _error = false;
  bool _verifying = false;
  bool _unlocked = false;

  void _tap(String d) {
    if (_verifying || _unlocked || _pin.length >= 4) return;
    setState(() {
      _error = false;
      _pin += d;
      _verifying = _pin.length == 4;
    });
    if (_verifying) {
      final entered = _pin;
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        setState(() {
          _verifying = false;
          _unlocked = entered == '1234';
          _error = !_unlocked;
          if (_error) _pin = '';
        });
      });
    }
  }

  void _back() {
    if (_verifying || _unlocked || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _lockAgain() {
    setState(() {
      _unlocked = false;
      _pin = '';
    });
  }

  void _useBiometrics() {
    final callback = widget.onUseBiometrics;
    if (callback != null) {
      callback();
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Biometric prompt goes here (demo)')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = _unlocked ? Colors.green : scheme.primary;

    return Scaffold(
      body: SafeArea(
        // Fills tall screens so the Spacer works, and scrolls on short ones.
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: _unlocked
                        ? Colors.green
                        : scheme.primaryContainer,
                    child: Icon(
                      _unlocked ? Icons.check : Icons.lock_outline,
                      size: 34,
                      color: _unlocked
                          ? Colors.white
                          : scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _unlocked ? 'Unlocked' : 'Enter your PIN',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _unlocked
                        ? 'PIN accepted'
                        : _error
                        ? 'Incorrect PIN, try again'
                        : 'Hint: 1234',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _unlocked
                          ? Colors.green
                          : _error
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      final filled = i < _pin.length;
                      return Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled ? accent : Colors.transparent,
                          border: Border.all(color: accent, width: 2),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  _Keypad(onTap: _tap, onBackspace: _back),
                  const SizedBox(height: 12),
                  _unlocked
                      ? TextButton.icon(
                          onPressed: _lockAgain,
                          icon: const Icon(Icons.lock_outline),
                          label: const Text('Lock again'),
                        )
                      : TextButton.icon(
                          onPressed: _useBiometrics,
                          icon: const Icon(Icons.fingerprint),
                          label: const Text('Use biometrics'),
                        ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', '⌫'],
  ];

  final void Function(String) onTap;
  final VoidCallback onBackspace;
  const _Keypad({required this.onTap, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    // Fixed key height: deriving it from the width made the grid taller than
    // the screen on tablets and desktops.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in _rows)
              Row(
                children: [
                  for (final k in row) Expanded(child: _key(context, k)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _key(BuildContext context, String k) {
    if (k.isEmpty) return const SizedBox();
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: () => k == '⌫' ? onBackspace() : onTap(k),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        alignment: Alignment.center,
        child: k == '⌫'
            ? const Icon(
                Icons.backspace_outlined,
                size: 26,
                semanticLabel: 'Delete digit',
              )
            : Text(
                k,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
