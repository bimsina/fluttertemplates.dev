import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _suggestions = [
  'flutter', 'dart', 'firebase', 'riverpod', 'bloc', 'animation',
  'material', 'cupertino', 'testing', 'accessibility', 'web', 'desktop',
];

class TagInput extends StatefulWidget {
  const TagInput({super.key});

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  static const _maxTags = 6;
  static const _maxLength = 20;

  final _controller = TextEditingController();
  late final _focus = FocusNode(onKeyEvent: _onKey);
  final _tags = <String>['flutter', 'animation'];

  /// Armed by the first backspace on an empty field; the second one deletes.
  /// Stops a held key from wiping every tag.
  var _lastArmed = false;
  String? _error;

  bool get _isFull => _tags.length >= _maxTags;

  List<String> get _matches {
    final query = _controller.text.trim().toLowerCase();
    return _suggestions
        .where((s) => !_tags.contains(s) && s.contains(query))
        .take(6)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.backspace ||
        _controller.text.isNotEmpty ||
        _tags.isEmpty) {
      if (_lastArmed) setState(() => _lastArmed = false);
      return KeyEventResult.ignored;
    }
    if (event is KeyRepeatEvent) return KeyEventResult.handled;
    setState(() {
      if (_lastArmed) {
        _tags.removeLast();
        _error = null;
      }
      _lastArmed = !_lastArmed;
    });
    return KeyEventResult.handled;
  }

  void _commit(String raw) {
    final tag = raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
    if (tag.isEmpty) return;
    setState(() {
      _lastArmed = false;
      if (_isFull) {
        _error = 'You can add up to $_maxTags tags';
      } else if (_tags.contains(tag)) {
        _error = '"$tag" is already added';
      } else {
        _tags.add(tag);
        _error = null;
        _controller.clear();
      }
    });
    _focus.requestFocus();
  }

  /// Commits on a comma, including every tag in a pasted, comma-separated list.
  void _onChanged(String value) {
    if (value.contains(',')) {
      final parts = value.split(',');
      final rest = parts.removeLast();
      parts.forEach(_commit);
      _controller.value = TextEditingValue(
        text: rest,
        selection: TextSelection.collapsed(offset: rest.length),
      );
      return;
    }
    setState(() {
      _lastArmed = false;
      if (!_isFull) _error = null;
    });
  }

  void _remove(String tag) {
    setState(() {
      _tags.remove(tag);
      _lastArmed = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final matches = _matches;

    return Scaffold(
      appBar: AppBar(title: const Text('New article')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _focus.requestFocus,
            child: InputDecorator(
              isFocused: _focus.hasFocus,
              isEmpty: false,
              decoration: InputDecoration(
                labelText: 'Tags',
                helperText: 'Press enter or comma to add',
                errorText: _error,
                counterText: '${_tags.length}/$_maxTags',
                border: const OutlineInputBorder(),
              ),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final (index, tag) in _tags.indexed)
                    InputChip(
                      key: ValueKey(tag),
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      selected: _lastArmed && index == _tags.length - 1,
                      showCheckmark: false,
                      onDeleted: () => _remove(tag),
                      deleteButtonTooltipMessage: 'Remove $tag',
                    ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 96, maxWidth: 200),
                    child: IntrinsicWidth(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        onChanged: _onChanged,
                        onSubmitted: _commit,
                        maxLength: _maxLength,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration.collapsed(
                          hintText: _isFull ? 'Limit reached' : 'Add a tag',
                        ).copyWith(counterText: ''),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (matches.isNotEmpty && !_isFull) ...[
            Text(
              _controller.text.isEmpty ? 'Popular' : 'Suggestions',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final tag in matches)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: Text(tag),
                    onPressed: () => _commit(tag),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _tags.isEmpty
                ? null
                : () => ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text('Saved: ${_tags.join(', ')}')),
                  ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
