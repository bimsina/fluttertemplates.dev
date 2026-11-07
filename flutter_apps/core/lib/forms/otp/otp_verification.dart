import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpVerification extends StatefulWidget {
  /// Called with the six digits once all are entered. Without it the demo
  /// shows a SnackBar.
  final ValueChanged<String>? onVerify;

  const OtpVerification({super.key, this.onVerify});

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  var _resendEnabled = false;
  var _resendCountdown = 30;
  Timer? _resendTimer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) _resendEnabled = true;
      });
      if (_resendCountdown <= 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _verify() {
    final firstEmpty = _controllers.indexWhere((c) => c.text.isEmpty);
    if (firstEmpty != -1) {
      setState(() => _error = 'Enter all 6 digits');
      _focusNodes[firstEmpty].requestFocus();
      return;
    }
    final onVerify = widget.onVerify;
    if (onVerify != null) {
      onVerify(_controllers.map((c) => c.text).join());
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Code accepted (demo)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text(
              'Enter the 6-digit code sent to your email',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                return Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 44),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onChanged: (v) {
                        if (_error != null) setState(() => _error = null);
                        if (v.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        } else if (v.isNotEmpty && i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(onPressed: _verify, child: const Text('Verify')),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _resendEnabled
                  ? () {
                      setState(() {
                        _resendEnabled = false;
                        _resendCountdown = 30;
                      });
                      _startResendTimer();
                    }
                  : null,
              child: Text(
                _resendEnabled
                    ? 'Resend code'
                    : 'Resend in $_resendCountdown s',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
