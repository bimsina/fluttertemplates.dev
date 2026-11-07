import 'dart:async';

import 'package:flutter/material.dart';

enum _Kind {
  photo('Photo', Icons.image_outlined),
  document('Document', Icons.description_outlined),
  audio('Audio', Icons.headphones_outlined),
  location('Location', Icons.place_outlined);

  const _Kind(this.label, this.icon);
  final String label;
  final IconData icon;
}

const _sampleNames = {
  _Kind.photo: ['IMG_2041.jpg', 'whiteboard.png', 'receipt.jpg'],
  _Kind.document: ['Q3-report.pdf', 'contract-v2.docx', 'budget.xlsx'],
  _Kind.audio: ['standup-notes.m4a', 'voice-memo.m4a'],
  _Kind.location: ['Current location', 'Office, 4th floor'],
};

class _Attachment {
  _Attachment(this.id, this.kind, this.name);

  final int id;
  final _Kind kind;
  final String name;

  /// 0 to 1 while uploading. Sending is blocked until everything reaches 1.
  double progress = 0;

  bool get isReady => progress >= 1;
}

class _Message {
  const _Message(this.text, this.attachments);

  final String text;
  final List<_Attachment> attachments;
}

class ChatMessageInput extends StatefulWidget {
  const ChatMessageInput({super.key});

  @override
  State<ChatMessageInput> createState() => _ChatMessageInputState();
}

class _ChatMessageInputState extends State<ChatMessageInput> {
  static const _maxAttachments = 4;

  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  final _messages = <_Message>[
    const _Message('Can you send over the files from this morning?', []),
  ];
  final _pending = <_Attachment>[];
  final _timers = <int, Timer>{};
  var _nextId = 0;
  var _trayOpen = false;

  bool get _uploading => _pending.any((a) => !a.isReady);

  bool get _canSend =>
      !_uploading &&
      (_pending.isNotEmpty || _controller.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _controller.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _attach(_Kind kind) {
    if (_pending.length >= _maxAttachments) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('You can attach up to $_maxAttachments items'),
          ),
        );
      return;
    }
    final names = _sampleNames[kind]!;
    final attachment = _Attachment(
      _nextId++,
      kind,
      names[_nextId % names.length],
    );
    setState(() {
      _pending.add(attachment);
      _trayOpen = false;
    });
    // Stands in for the upload stream from your storage client.
    _timers[attachment.id] = Timer.periodic(
      const Duration(milliseconds: 90),
      (timer) {
        setState(() => attachment.progress += 0.06);
        if (attachment.isReady) {
          timer.cancel();
          _timers.remove(attachment.id);
        }
      },
    );
  }

  void _remove(_Attachment attachment) {
    _timers.remove(attachment.id)?.cancel();
    setState(() => _pending.remove(attachment));
  }

  void _send() {
    if (!_canSend) return;
    setState(() {
      _messages.add(_Message(_controller.text.trim(), [..._pending]));
      _pending.clear();
      _controller.clear();
      _trayOpen = false;
    });
    _focus.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Priya Raman')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _Bubble(
                message: _messages[index],
                mine: index != 0,
              ),
            ),
          ),
          Material(
            color: scheme.surfaceContainerLow,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_pending.isNotEmpty)
                    SizedBox(
                      height: 68,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                        itemCount: _pending.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) => _PendingTile(
                          attachment: _pending[index],
                          onRemove: () => _remove(_pending[index]),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 8, 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: _trayOpen ? 'Close' : 'Attach',
                          onPressed: () =>
                              setState(() => _trayOpen = !_trayOpen),
                          icon: AnimatedRotation(
                            turns: _trayOpen ? 0.125 : 0,
                            duration: const Duration(milliseconds: 160),
                            child: const Icon(Icons.add),
                          ),
                        ),
                        Expanded(
                          child: _ComposerField(
                            controller: _controller,
                            focusNode: _focus,
                            onSubmit: _send,
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton.filled(
                          tooltip: _uploading ? 'Uploading' : 'Send',
                          onPressed: _canSend ? _send : null,
                          icon: const Icon(Icons.arrow_upward),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: _trayOpen
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
                            child: Row(
                              children: [
                                for (final kind in _Kind.values)
                                  Expanded(
                                    child: _TrayButton(
                                      kind: kind,
                                      onTap: () => _attach(kind),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grows to five lines, then scrolls inside itself.
class _ComposerField extends StatelessWidget {
  const _ComposerField({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      minLines: 1,
      maxLines: 5,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) {
        onSubmit();
      },
      decoration: InputDecoration(
        hintText: 'Message',
        isDense: true,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _TrayButton extends StatelessWidget {
  const _TrayButton({required this.kind, required this.onTap});

  final _Kind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: scheme.secondaryContainer,
              foregroundColor: scheme.onSecondaryContainer,
              child: Icon(kind.icon),
            ),
            const SizedBox(height: 6),
            Text(
              kind.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingTile extends StatelessWidget {
  const _PendingTile({required this.attachment, required this.onRemove});

  final _Attachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: 164,
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 28,
            child: attachment.isReady
                ? Icon(attachment.kind.icon, size: 22, color: scheme.primary)
                : CircularProgressIndicator(
                    value: attachment.progress.clamp(0.0, 1.0),
                    strokeWidth: 3,
                    backgroundColor: scheme.outlineVariant,
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              attachment.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
          ),
          IconButton(
            tooltip: 'Remove ${attachment.name}',
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final _Message message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = mine ? scheme.onPrimary : scheme.onSurface;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: mine ? scheme.primary : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final a in message.attachments)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(a.kind.icon, size: 18, color: foreground),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        a.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: foreground,
                          decoration: TextDecoration.underline,
                          decorationColor: foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (message.text.isNotEmpty)
              Text(
                message.text,
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: foreground),
              ),
          ],
        ),
      ),
    );
  }
}
