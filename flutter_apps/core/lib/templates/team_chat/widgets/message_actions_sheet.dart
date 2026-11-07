import 'package:flutter/material.dart';

import '../models/message.dart';
import 'chat_style.dart';

/// Quick reactions and actions for one message.
Future<void> showMessageActions(
  BuildContext context, {
  required Message message,
  required String myId,
  required bool canDelete,
  bool canRespond = true,
  required ValueChanged<ReactionKind> onReact,
  required VoidCallback onReply,
  required VoidCallback onCopy,
  required VoidCallback onDelete,
}) {
  void run(BuildContext sheetContext, VoidCallback action) {
    Navigator.of(sheetContext).pop();
    action();
  }

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canRespond) ...[
                Row(
                  children: [
                    for (final kind in ReactionKind.values)
                      Expanded(
                        child: _ReactionButton(
                          kind: kind,
                          isActive:
                              message.reactions[kind]?.contains(myId) ?? false,
                          onTap: () => run(sheetContext, () => onReact(kind)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.reply_rounded),
                  title: const Text('Reply'),
                  onTap: () => run(sheetContext, onReply),
                ),
              ],
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Copy text'),
                onTap: () => run(sheetContext, onCopy),
              ),
              if (canDelete)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Delete',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () => run(sheetContext, onDelete),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.kind,
    required this.isActive,
    required this.onTap,
  });

  final ReactionKind kind;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: AspectRatio(
        aspectRatio: 1,
        child: Material(
          color: isActive ? scheme.primaryContainer : scheme.raised,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            tooltip: reactionLabel(kind),
            onPressed: onTap,
            isSelected: isActive,
            padding: EdgeInsets.zero,
            icon: Icon(
              reactionIcon(kind),
              size: 22,
              color: isActive
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
