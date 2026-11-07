import 'package:flutter/material.dart';

class OverlayDialogs extends StatefulWidget {
  const OverlayDialogs({super.key});

  @override
  State<OverlayDialogs> createState() => _OverlayDialogsState();
}

class _OverlayDialogsState extends State<OverlayDialogs> {
  var _result = 'Open a dialog to see what it returns.';

  void _showResult(String result) {
    if (mounted) setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialogs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Confirmation Dialog'),
            onTap: _showConfirmDialog,
          ),
          ListTile(
            title: const Text('Input Dialog'),
            onTap: _showInputDialog,
          ),
          ListTile(
            title: const Text('Multi-Choice Dialog'),
            onTap: _showMultiChoiceDialog,
          ),
          ListTile(
            title: const Text('Loading Dialog'),
            onTap: _showLoadingDialog,
          ),
          const Divider(),
          ListTile(
            title: const Text('Last result'),
            subtitle: Text(_result),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    _showResult(confirmed == true ? 'Confirmed' : 'Cancelled');
  }

  Future<void> _showInputDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _NameDialog(),
    );
    _showResult(name == null ? 'Cancelled' : 'Name: $name');
  }

  Future<void> _showMultiChoiceDialog() async {
    final options = await showDialog<Set<String>>(
      context: context,
      builder: (_) => const _MultiChoiceDialog(),
    );
    if (options == null) {
      _showResult('Cancelled');
    } else if (options.isEmpty) {
      _showResult('Selected: none');
    } else {
      _showResult('Selected: ${options.join(', ')}');
    }
  }

  Future<void> _showLoadingDialog() async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final closed = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 24),
              Text('Loading...'),
            ],
          ),
        ),
      ),
    );
    // Simulated: replace the delay with your real request.
    await Future<void>.delayed(const Duration(seconds: 2));
    navigator.pop();
    await closed;
    _showResult('Loading finished');
  }
}

/// Owns its controller so it is disposed after the closing animation.
class _NameDialog extends StatefulWidget {
  const _NameDialog();

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter name'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Your name',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _MultiChoiceDialog extends StatefulWidget {
  const _MultiChoiceDialog();

  @override
  State<_MultiChoiceDialog> createState() => _MultiChoiceDialogState();
}

class _MultiChoiceDialogState extends State<_MultiChoiceDialog> {
  static const _options = ['A', 'B', 'C'];

  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in _options)
            CheckboxListTile(
              title: Text('Option $option'),
              value: _selected.contains(option),
              onChanged: (checked) => setState(() {
                checked == true
                    ? _selected.add(option)
                    : _selected.remove(option);
              }),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, {
            for (final option in _options)
              if (_selected.contains(option)) option,
          }),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
