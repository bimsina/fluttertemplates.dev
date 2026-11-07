import 'dart:async';
import 'package:flutter/material.dart';

class TwoFactor extends StatefulWidget {
  const TwoFactor({super.key});

  @override
  State<TwoFactor> createState() => _TwoFactorState();
}

class _TwoFactorState extends State<TwoFactor> {
  static const _demoCode = '123456';

  String _code = '';
  int _seconds = 30;
  Timer? _timer;
  Timer? _verifyTimer;
  bool _verifying = false;
  bool _verified = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
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
    _verifyTimer?.cancel();
    super.dispose();
  }

  bool get _locked => _verifying || _verified;

  void _resend() {
    setState(() {
      _seconds = 30;
      _code = '';
      _error = false;
    });
    _startTimer();
  }

  void _tap(String d) {
    if (_locked || _code.length >= 6) return;
    setState(() {
      _error = false;
      _code += d;
    });
    if (_code.length == 6) _submit();
  }

  void _submit() {
    setState(() => _verifying = true);
    _verifyTimer = Timer(const Duration(milliseconds: 600), () {
      final valid = _code == _demoCode;
      if (valid) _timer?.cancel();
      setState(() {
        _verifying = false;
        _verified = valid;
        _error = !valid;
        if (!valid) _code = '';
      });
    });
  }

  void _back() {
    if (_locked || _code.isEmpty) return;
    setState(() {
      _error = false;
      _code = _code.substring(0, _code.length - 1);
    });
  }

  String get _statusText {
    if (_verified) return 'Code verified';
    if (_verifying) return 'Verifying…';
    if (_error) return 'Incorrect code, try again';
    return 'Hint: $_demoCode';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor = _verified
        ? Colors.green
        : _error
        ? scheme.error
        : scheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
      // Fills tall screens so the Spacer works, and scrolls on short ones.
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    Icons.verified_user_outlined,
                    size: 56,
                    color: scheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Two-factor authentication',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 6-digit code sent to •••• 4821',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      final filled = i < _code.length;
                      // Flexible lets all six share a narrow screen; 44 is the cap.
                      return Flexible(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 44),
                          height: 54,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _verified
                                  ? Colors.green
                                  : filled
                                  ? scheme.primary
                                  : scheme.outlineVariant,
                              width: filled ? 2 : 1,
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              filled ? _code[i] : '',
                              style: theme.textTheme.headlineSmall,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(_statusText, style: TextStyle(color: statusColor)),
                  const SizedBox(height: 8),
                  if (!_verified)
                    _seconds > 0
                        ? Text(
                            'Resend code in 0:${_seconds.toString().padLeft(2, '0')}',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          )
                        : TextButton(
                            onPressed: _verifying ? null : _resend,
                            child: const Text('Resend code'),
                          ),
                  const Spacer(),
                  _Keypad(onTap: _tap, onBackspace: _back),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
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
      constraints: const BoxConstraints(maxWidth: 340),
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
    );
  }

  Widget _key(BuildContext context, String k) {
    if (k.isEmpty) return const SizedBox();
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: () => k == '⌫' ? onBackspace() : onTap(k),
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        alignment: Alignment.center,
        child: k == '⌫'
            ? const Icon(
                Icons.backspace_outlined,
                semanticLabel: 'Delete digit',
              )
            : Text(k, style: Theme.of(context).textTheme.headlineSmall),
      ),
    );
  }
}
