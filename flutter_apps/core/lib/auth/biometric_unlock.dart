import 'package:flutter/material.dart';

class BiometricUnlock extends StatefulWidget {
  const BiometricUnlock({super.key});

  @override
  State<BiometricUnlock> createState() => _BiometricUnlockState();
}

class _BiometricUnlockState extends State<BiometricUnlock> {
  bool _scanning = false;
  bool _unlocked = false;

  void _scan() {
    setState(() => _scanning = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _unlocked = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _unlocked ? Colors.green : scheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Text('Nimbus is locked',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_unlocked
                  ? 'Unlocked'
                  : _scanning
                      ? 'Scanning…'
                      : 'Tap to unlock with Face ID or Touch ID'),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: _scanning || _unlocked ? null : _scan,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: _scanning ? 0.25 : 0.12),
                    border: Border.all(color: color, width: 3),
                  ),
                  child: Icon(
                    _unlocked
                        ? Icons.lock_open_rounded
                        : Icons.fingerprint,
                    size: 72,
                    color: color,
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.dialpad),
                label: const Text('Use passcode instead'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
