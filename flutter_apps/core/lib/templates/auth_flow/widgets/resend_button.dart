import 'dart:async';

import 'package:flutter/material.dart';

/// A resend action with a cooldown, which starts as soon as it appears since
/// the first message has only just been sent.
class ResendButton extends StatefulWidget {
  const ResendButton({
    super.key,
    required this.label,
    required this.onResend,
    this.cooldown = const Duration(seconds: 30),
    this.skipCooldown = false,
    this.isEnabled = true,
  });

  final String label;

  /// Returns whether the send worked. The cooldown only restarts if it did.
  final Future<bool> Function() onResend;
  final Duration cooldown;

  /// Makes the button usable right away, for when the earlier message is
  /// already known to be useless, such as an expired code.
  final bool skipCooldown;
  final bool isEnabled;

  @override
  State<ResendButton> createState() => _ResendButtonState();
}

class _ResendButtonState extends State<ResendButton> {
  Timer? _timer;
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    _timer?.cancel();
    _secondsLeft = widget.cooldown.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  Future<void> _resend() async {
    final didSend = await widget.onResend();
    if (didSend && mounted) setState(_startCooldown);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWaiting = _secondsLeft > 0 && !widget.skipCooldown;
    return TextButton(
      onPressed: isWaiting || !widget.isEnabled ? null : _resend,
      child: Text(
        isWaiting ? '${widget.label} in ${_secondsLeft}s' : widget.label,
        textAlign: TextAlign.center,
      ),
    );
  }
}
