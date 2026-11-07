import 'package:flutter/material.dart';

import '../state/auth_controller.dart';
import '../state/auth_scope.dart';

/// Shows [AuthController.notice] above the navigator, so a message survives
/// the route change that caused it and never covers the form below.
class NoticeStrip extends StatelessWidget {
  const NoticeStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context).auth;
    final notice = auth.notice;
    return AnimatedSize(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: notice == null
          ? const SizedBox(width: double.infinity)
          : _Strip(notice: notice, onDismiss: auth.dismissNotice),
    );
  }
}

class _Strip extends StatelessWidget {
  const _Strip({required this.notice, required this.onDismiss});

  final AuthNotice notice;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground, icon) = switch (notice.tone) {
      NoticeTone.info => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        Icons.info_outline,
      ),
      NoticeTone.success => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
        Icons.check_circle_outline,
      ),
      NoticeTone.warning => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.schedule,
      ),
    };

    return Material(
      color: background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
          child: Row(
            children: [
              Icon(icon, size: 20, color: foreground),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    notice.message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: foreground),
                  ),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                tooltip: 'Dismiss message',
                color: foreground,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
