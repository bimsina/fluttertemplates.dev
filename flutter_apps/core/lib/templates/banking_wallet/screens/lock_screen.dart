import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../state/wallet_controller.dart';
import '../state/wallet_scope.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/stitched_panel.dart';
import '../widgets/wallet_theme.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  String _pin = '';
  bool _checking = false;
  bool _checkFailed = false;
  String? _error;
  Timer? _cooldownTicker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startCooldownTicker();
  }

  @override
  void dispose() {
    _cooldownTicker?.cancel();
    _shake.dispose();
    super.dispose();
  }

  /// Seconds left before another attempt is allowed.
  int _cooldownSeconds(WalletController wallet) {
    final until = wallet.pinLockedUntil;
    if (until == null) return 0;
    final remaining = until.difference(DateTime.now());
    return remaining.isNegative ? 0 : remaining.inSeconds + 1;
  }

  void _startCooldownTicker() {
    final wallet = WalletScope.read(context);
    if (_cooldownTicker != null || _cooldownSeconds(wallet) == 0) return;
    _cooldownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final finished = _cooldownSeconds(wallet) == 0;
      setState(() {
        if (finished) _error = null;
      });
      if (finished) {
        timer.cancel();
        _cooldownTicker = null;
      }
    });
  }

  void _onDigit(String digit) {
    final wallet = WalletScope.read(context);
    if (_checking || _cooldownSeconds(wallet) > 0) return;
    if (_pin.length >= wallet.pinLength) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == wallet.pinLength) _submit(wallet);
  }

  void _onBackspace() {
    if (_checking || _pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      if (_checkFailed) {
        _checkFailed = false;
        _error = null;
      }
    });
  }

  Future<void> _submit(WalletController wallet) async {
    setState(() {
      _checking = true;
      _checkFailed = false;
      _error = null;
    });
    final result = await wallet.submitPin(_pin);
    // A correct PIN leaves the keypad off while this screen fades out.
    if (!mounted || result == PinResult.correct) return;

    if (result == PinResult.unavailable) {
      // The PIN wasn't judged, so keep it for the retry and don't shake.
      setState(() {
        _checking = false;
        _checkFailed = true;
        _error = "Couldn't check your PIN. Check your connection.";
      });
      return;
    }

    final attemptsLeft =
        WalletController.maxPinAttempts - wallet.failedPinAttempts;
    setState(() {
      _checking = false;
      _pin = '';
      _error = result == PinResult.lockedOut
          ? null
          : 'Wrong PIN. $attemptsLeft '
                '${attemptsLeft == 1 ? 'try' : 'tries'} left.';
    });
    _shake.forward(from: 0);
    _startCooldownTicker();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = WalletScope.of(context);
    final cooldown = _cooldownSeconds(wallet);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440, maxHeight: 820),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: SizedBox(
                    height: max(constraints.maxHeight, 520),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 9,
                            child: _buildPanel(context, wallet, cooldown),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            flex: 10,
                            child: NumericKeypad(
                              enabled: !_checking && cooldown == 0,
                              onKey: _onDigit,
                              onBackspace: _onBackspace,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(
    BuildContext context,
    WalletController wallet,
    int cooldown,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final message = cooldown > 0
        ? 'Too many tries. Wait ${cooldown}s.'
        : (_error ?? 'Enter your ${wallet.pinLength}-digit PIN');
    final hint = wallet.pinHint;

    return StitchedPanel(
      notch: 0,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                brandName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                wallet.customer == null
                    ? 'Welcome back'
                    : 'Welcome back, ${wallet.customer!.firstName}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _shake,
                builder: (context, child) {
                  final progress = _shake.value;
                  final offset = sin(progress * pi * 5) * 10 * (1 - progress);
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: _PinDots(
                  length: wallet.pinLength,
                  filled: _pin.length,
                  color: scheme.onPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: _error == null && cooldown == 0
                        ? FontWeight.w400
                        : FontWeight.w700,
                  ),
                ),
              ),
              if (_checkFailed) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _submit(wallet),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onPrimary,
                  ),
                  child: const Text('Try again'),
                ),
              ],
              if (hint != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Demo PIN: $hint',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onPrimary,
                      fontFeatures: tabularFigures,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.length,
    required this.filled,
    required this.color,
  });

  final int length;
  final int filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$filled of $length digits entered',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < length; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              margin: const EdgeInsets.symmetric(horizontal: 9),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < filled ? color : Colors.transparent,
                border: Border.all(color: color, width: 2),
              ),
            ),
        ],
      ),
    );
  }
}
