import 'dart:async';
import 'package:flutter/material.dart';

class TwoFactor extends StatefulWidget {
  const TwoFactor({super.key});

  @override
  State<TwoFactor> createState() => _TwoFactorState();
}

class _TwoFactorState extends State<TwoFactor> {
  String _code = '';
  int _seconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _seconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tap(String d) {
    if (_code.length < 6) setState(() => _code += d);
  }

  void _back() {
    if (_code.isNotEmpty) {
      setState(() => _code = _code.substring(0, _code.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Icon(Icons.verified_user_outlined, size: 56, color: scheme.primary),
          const SizedBox(height: 16),
          Text('Two-factor authentication',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Enter the 6-digit code sent to •••• 4821',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              final filled = i < _code.length;
              return Container(
                width: 44,
                height: 54,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: filled ? scheme.primary : scheme.outlineVariant,
                    width: filled ? 2 : 1,
                  ),
                ),
                child: Text(filled ? _code[i] : '',
                    style: theme.textTheme.headlineSmall),
              );
            }),
          ),
          const SizedBox(height: 20),
          _seconds > 0
              ? Text('Resend code in 0:${_seconds.toString().padLeft(2, '0')}',
                  style: TextStyle(color: scheme.onSurfaceVariant))
              : TextButton(
                  onPressed: _startTimer, child: const Text('Resend code')),
          const Spacer(),
          _Keypad(onTap: _tap, onBackspace: _back),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final void Function(String) onTap;
  final VoidCallback onBackspace;
  const _Keypad({required this.onTap, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        childAspectRatio: 1.8,
        physics: const NeverScrollableScrollPhysics(),
        children: keys.map((k) {
          if (k.isEmpty) return const SizedBox();
          return InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () => k == '⌫' ? onBackspace() : onTap(k),
            child: Center(
              child: k == '⌫'
                  ? const Icon(Icons.backspace_outlined)
                  : Text(k, style: Theme.of(context).textTheme.headlineSmall),
            ),
          );
        }).toList(),
      ),
    );
  }
}
