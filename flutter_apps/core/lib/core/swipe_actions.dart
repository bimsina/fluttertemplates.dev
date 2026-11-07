import 'dart:math' as math;

import 'package:flutter/material.dart';

class _Mail {
  _Mail(this.sender, this.subject, this.time);

  final String sender;
  final String subject;
  final String time;
  var unread = true;
  var flagged = false;
}

class _SwipeAction {
  const _SwipeAction({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
}

class SwipeActionsList extends StatefulWidget {
  const SwipeActionsList({super.key});

  @override
  State<SwipeActionsList> createState() => _SwipeActionsListState();
}

class _SwipeActionsListState extends State<SwipeActionsList> {
  final _mail = [
    _Mail('Stripe', 'Your October payout is on the way', '09:12'),
    _Mail('Nora Lindqvist', 'Notes from the roadmap review', '08:47'),
    _Mail('GitHub', 'Dependabot opened 3 pull requests', '08:05'),
    _Mail('Vercel', 'Deployment failed on main', 'Tue'),
    _Mail('Marco Bianchi', 'Lunch on Thursday?', 'Tue'),
    _Mail('Figma', 'Elena commented on Checkout flow', 'Mon'),
    _Mail('Linear', 'Weekly digest for your team', 'Mon'),
    _Mail('Dana Wu', 'Offer letter draft', 'Sun'),
  ];

  /// The row currently holding its actions open. Only one may be open at a time.
  final _openRow = ValueNotifier<_Mail?>(null);

  @override
  void dispose() {
    _openRow.dispose();
    super.dispose();
  }

  void _removeWithUndo(_Mail mail, String verb) {
    final index = _mail.indexOf(mail);
    setState(() => _mail.removeAt(index));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$verb "${mail.subject}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => setState(() => _mail.insert(index, mail)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Inbox (${_mail.length})')),
      body: _mail.isEmpty
          ? const Center(child: Text('Inbox zero'))
          : ListView.separated(
              itemCount: _mail.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final mail = _mail[index];
                return _SwipeRow(
                  key: ObjectKey(mail),
                  id: mail,
                  openRow: _openRow,
                  leading: [
                    _SwipeAction(
                      label: mail.unread ? 'Read' : 'Unread',
                      icon: mail.unread
                          ? Icons.mark_email_read_outlined
                          : Icons.mark_email_unread_outlined,
                      background: scheme.primaryContainer,
                      foreground: scheme.onPrimaryContainer,
                      onTap: () => setState(() => mail.unread = !mail.unread),
                    ),
                  ],
                  trailing: [
                    _SwipeAction(
                      label: mail.flagged ? 'Unflag' : 'Flag',
                      icon: mail.flagged ? Icons.flag : Icons.flag_outlined,
                      background: scheme.tertiaryContainer,
                      foreground: scheme.onTertiaryContainer,
                      onTap: () =>
                          setState(() => mail.flagged = !mail.flagged),
                    ),
                    _SwipeAction(
                      label: 'Delete',
                      icon: Icons.delete_outline,
                      background: scheme.errorContainer,
                      foreground: scheme.onErrorContainer,
                      onTap: () => _removeWithUndo(mail, 'Deleted'),
                    ),
                  ],
                  child: _MailTile(mail: mail),
                );
              },
            ),
    );
  }
}

/// Reveals actions behind a row. Dragging past [_commitFraction] of the width
/// runs the outermost action on that side, like Mail on iOS.
class _SwipeRow extends StatefulWidget {
  const _SwipeRow({
    super.key,
    required this.id,
    required this.openRow,
    required this.leading,
    required this.trailing,
    required this.child,
  });

  final _Mail id;
  final ValueNotifier<_Mail?> openRow;
  final List<_SwipeAction> leading;
  final List<_SwipeAction> trailing;
  final Widget child;

  @override
  State<_SwipeRow> createState() => _SwipeRowState();
}

class _SwipeRowState extends State<_SwipeRow>
    with SingleTickerProviderStateMixin {
  static const _actionWidth = 76.0;
  static const _commitFraction = 0.6;

  /// Holds the signed horizontal offset of the row in pixels.
  late final _offset = AnimationController.unbounded(vsync: this);

  double get _leadingWidth => widget.leading.length * _actionWidth;
  double get _trailingWidth => widget.trailing.length * _actionWidth;

  @override
  void initState() {
    super.initState();
    widget.openRow.addListener(_closeIfAnotherOpened);
  }

  @override
  void dispose() {
    widget.openRow.removeListener(_closeIfAnotherOpened);
    _offset.dispose();
    super.dispose();
  }

  void _closeIfAnotherOpened() {
    if (widget.openRow.value != widget.id && _offset.value != 0) _settle(0);
  }

  void _settle(double target) {
    _offset.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _close() {
    if (widget.openRow.value == widget.id) widget.openRow.value = null;
    _settle(0);
  }

  void _onDragStart(DragStartDetails _) {
    _offset.stop();
    widget.openRow.value = widget.id;
  }

  void _onDragUpdate(DragUpdateDetails details, double width) {
    _offset.value = (_offset.value + details.delta.dx).clamp(
      widget.trailing.isEmpty ? 0.0 : -width,
      widget.leading.isEmpty ? 0.0 : width,
    );
  }

  void _onDragEnd(DragEndDetails details, double width) {
    final value = _offset.value;
    final velocity = details.primaryVelocity ?? 0;

    if (value.abs() > width * _commitFraction) {
      final action = value > 0 ? widget.leading.first : widget.trailing.last;
      _close();
      action.onTap();
      return;
    }

    final flungOpen = velocity.abs() > 400 && velocity.sign == value.sign;
    if (value > 0 && (value > _leadingWidth / 2 || flungOpen)) {
      _settle(_leadingWidth);
    } else if (value < 0 && (-value > _trailingWidth / 2 || flungOpen)) {
      _settle(-_trailingWidth);
    } else {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: (d) => _onDragUpdate(d, width),
          onHorizontalDragEnd: (d) => _onDragEnd(d, width),
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _offset,
              child: widget.child,
              builder: (context, child) {
                final offset = _offset.value;
                final actions = offset > 0 ? widget.leading : widget.trailing;
                return Stack(
                  children: [
                    if (offset != 0)
                      Positioned.fill(
                        child: Align(
                          alignment: offset > 0
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: SizedBox(
                            width: offset.abs(),
                            child: Row(
                              children: [
                                for (final action in actions)
                                  Expanded(
                                    child: _ActionButton(
                                      action: action,
                                      onTap: () {
                                        _close();
                                        action.onTap();
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Transform.translate(
                      offset: Offset(offset, 0),
                      child: GestureDetector(
                        // While open, a tap on the row closes it instead of
                        // opening the item underneath.
                        onTap: offset != 0 ? _close : null,
                        child: Material(
                          color: Theme.of(context).colorScheme.surface,
                          child: AbsorbPointer(
                            absorbing: offset != 0,
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action, required this.onTap});

  final _SwipeAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: action.background,
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Fades in once there is room, rather than squashing the label.
            final opacity =
                math.min(1.0, math.max(0.0, constraints.maxWidth / 60 - 0.3));
            return OverflowBox(
              minWidth: 76,
              maxWidth: 76,
              child: Opacity(
                opacity: opacity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(action.icon, color: action.foreground),
                    const SizedBox(height: 4),
                    Text(
                      action.label,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: action.foreground),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MailTile extends StatelessWidget {
  const _MailTile({required this.mail});

  final _Mail mail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
        child: Text(mail.sender[0]),
      ),
      title: Text(
        mail.sender,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: mail.unread ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      subtitle: Text(
        mail.subject,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(mail.time, style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          if (mail.flagged)
            Icon(Icons.flag, size: 16, color: scheme.tertiary)
          else if (mail.unread)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
