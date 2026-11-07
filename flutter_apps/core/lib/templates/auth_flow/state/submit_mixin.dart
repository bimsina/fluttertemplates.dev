import 'package:flutter/widgets.dart';

import '../models/auth_failure.dart';

/// The busy and error state every form shares.
///
/// Calling [submit] again while a request runs does nothing, so a double tap
/// or a held Enter key can't send it twice. The form keeps what was typed, so
/// the same submit button is the retry.
mixin SubmitMixin<T extends StatefulWidget> on State<T> {
  bool isBusy = false;
  AuthFailure? failure;

  /// Runs [request] and returns whether it worked. The state may be disposed
  /// by the time it finishes, because success usually swaps the route.
  Future<bool> submit(Future<void> Function() request) async {
    if (isBusy) return false;
    setState(() {
      isBusy = true;
      failure = null;
    });
    try {
      await request();
      if (mounted) setState(() => isBusy = false);
      return true;
    } on AuthFailure catch (error) {
      if (mounted) {
        setState(() {
          isBusy = false;
          failure = error;
        });
      }
      return false;
    }
  }
}
