import 'package:flutter/material.dart';

enum _StepState { upcoming, current, complete, error }

class _StepInfo {
  const _StepInfo(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

const _steps = [
  _StepInfo('Workspace', 'Name your team'),
  _StepInfo('Plan', 'Choose a seat count'),
  _StepInfo('Invite', 'Add a teammate'),
  _StepInfo('Review', 'Confirm the details'),
];

class ProgressStepper extends StatefulWidget {
  const ProgressStepper({super.key});

  @override
  State<ProgressStepper> createState() => _ProgressStepperState();
}

class _ProgressStepperState extends State<ProgressStepper> {
  final _workspace = TextEditingController();
  final _email = TextEditingController();
  var _seats = 5;

  var _current = 0;

  /// Furthest step reached, so users can jump back and forward again.
  var _reached = 0;
  var _vertical = false;
  var _finished = false;

  /// Steps that failed validation. Cleared as soon as they pass.
  final _invalid = <int>{};

  @override
  void dispose() {
    _workspace.dispose();
    _email.dispose();
    super.dispose();
  }

  bool _isValid(int step) => switch (step) {
        0 => _workspace.text.trim().length >= 3,
        // Inviting is optional, but anything typed has to look like an email.
        2 => _email.text.isEmpty || _email.text.contains('@'),
        _ => true,
      };

  _StepState _stateOf(int step) {
    if (_invalid.contains(step)) return _StepState.error;
    if (step == _current) return _StepState.current;
    return step <= _reached ? _StepState.complete : _StepState.upcoming;
  }

  void _goTo(int step) {
    // Forward jumps stop at the first step that fails, so nothing is skipped.
    for (var i = _current; i < step; i++) {
      if (!_isValid(i)) {
        setState(() => _invalid.add(i));
        return;
      }
    }
    setState(() {
      _invalid.remove(_current);
      _current = step;
      if (step > _reached) _reached = step;
    });
  }

  void _next() {
    if (_current < _steps.length - 1) {
      _goTo(_current + 1);
    } else {
      setState(() => _finished = true);
    }
  }

  void _restart() {
    _workspace.clear();
    _email.clear();
    setState(() {
      _seats = 5;
      _current = 0;
      _reached = 0;
      _finished = false;
      _invalid.clear();
    });
  }

  Widget _content(int step) {
    final theme = Theme.of(context);
    return switch (step) {
      0 => TextField(
          controller: _workspace,
          onChanged: (_) => setState(() {
            if (_isValid(0)) _invalid.remove(0);
          }),
          decoration: InputDecoration(
            labelText: 'Workspace name',
            border: const OutlineInputBorder(),
            errorText: _invalid.contains(0) ? 'Use at least 3 characters' : null,
          ),
        ),
      1 => Row(
          children: [
            Expanded(
              child: Text('$_seats seats', style: theme.textTheme.titleMedium),
            ),
            IconButton.outlined(
              tooltip: 'Fewer seats',
              onPressed:
                  _seats > 1 ? () => setState(() => _seats--) : null,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              tooltip: 'More seats',
              onPressed:
                  _seats < 50 ? () => setState(() => _seats++) : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      2 => TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {
            if (_isValid(2)) _invalid.remove(2);
          }),
          decoration: InputDecoration(
            labelText: 'Teammate email (optional)',
            border: const OutlineInputBorder(),
            errorText: _invalid.contains(2) ? 'Enter a valid email' : null,
          ),
        ),
      _ => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Workspace: ${_workspace.text.trim()}'),
            const SizedBox(height: 4),
            Text('Seats: $_seats'),
            const SizedBox(height: 4),
            Text(
              'Invite: ${_email.text.isEmpty ? 'Nobody yet' : _email.text}',
            ),
          ],
        ),
    };
  }

  Widget _controls() {
    final isLast = _current == _steps.length - 1;
    return Row(
      children: [
        FilledButton(
          onPressed: _next,
          child: Text(isLast ? 'Finish' : 'Continue'),
        ),
        const SizedBox(width: 8),
        if (_current > 0)
          TextButton(
            onPressed: () => _goTo(_current - 1),
            child: const Text('Back'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up workspace'),
        actions: [
          IconButton(
            tooltip: _vertical ? 'Horizontal layout' : 'Vertical layout',
            onPressed: () => setState(() => _vertical = !_vertical),
            icon: Icon(
              _vertical ? Icons.view_week_outlined : Icons.view_agenda_outlined,
            ),
          ),
        ],
      ),
      body: _finished
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 56, color: scheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    '${_workspace.text.trim()} is ready',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _restart,
                    child: const Text('Start over'),
                  ),
                ],
              ),
            )
          : _vertical
              ? _buildVertical()
              : _buildHorizontal(),
    );
  }

  Widget _buildHorizontal() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final step = _steps[_current];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            for (var i = 0; i < _steps.length; i++) ...[
              _Node(
                index: i,
                state: _stateOf(i),
                semanticLabel: _steps[i].title,
                onTap: () => _goTo(i),
              ),
              if (i < _steps.length - 1)
                Expanded(child: _Connector(done: i < _reached)),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Step ${_current + 1} of ${_steps.length}',
          style: theme.textTheme.labelMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(step.title, style: theme.textTheme.headlineSmall),
        Text(
          step.subtitle,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: KeyedSubtree(
            key: ValueKey(_current),
            child: _content(_current),
          ),
        ),
        const SizedBox(height: 20),
        _controls(),
      ],
    );
  }

  Widget _buildVertical() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _steps.length,
      itemBuilder: (context, i) {
        final isCurrent = i == _current;
        final isLast = i == _steps.length - 1;
        // A Stack rather than IntrinsicHeight: the rail follows the content
        // through its size animation without a second layout pass.
        return Stack(
          children: [
            if (!isLast)
              Positioned(
                left: 16,
                top: 34,
                bottom: 0,
                child: _Connector(done: i < _reached, vertical: true),
              ),
            Positioned(
              left: 0,
              top: 0,
              child: _Node(
                index: i,
                state: _stateOf(i),
                semanticLabel: _steps[i].title,
                onTap: () => _goTo(i),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 46, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(_steps[i].title, style: theme.textTheme.titleSmall),
                  Text(
                    _steps[i].subtitle,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: isCurrent
                        ? Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _content(i),
                                const SizedBox(height: 14),
                                _controls(),
                              ],
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({
    required this.index,
    required this.state,
    required this.semanticLabel,
    required this.onTap,
  });

  final int index;
  final _StepState state;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (background, foreground, border) = switch (state) {
      _StepState.complete => (scheme.primary, scheme.onPrimary, scheme.primary),
      _StepState.current => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          scheme.primary,
        ),
      _StepState.error => (scheme.error, scheme.onError, scheme.error),
      _StepState.upcoming => (
          scheme.surface,
          scheme.onSurfaceVariant,
          scheme.outlineVariant,
        ),
    };

    return Semantics(
      button: true,
      label: '$semanticLabel, step ${index + 1}, ${state.name}',
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 2),
          ),
          child: switch (state) {
            _StepState.complete => Icon(Icons.check, size: 18, color: foreground),
            _StepState.error => Icon(Icons.priority_high, size: 18, color: foreground),
            _ => Text(
                '${index + 1}',
                style:
                    theme.textTheme.labelLarge?.copyWith(color: foreground),
              ),
          },
        ),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.done, this.vertical = false});

  final bool done;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: vertical ? 2 : null,
      height: vertical ? null : 2,
      margin: vertical
          ? const EdgeInsets.symmetric(vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 4),
      color: done ? scheme.primary : scheme.outlineVariant,
    );
  }
}
