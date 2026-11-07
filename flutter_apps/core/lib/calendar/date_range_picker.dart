import 'package:flutter/material.dart';

class DateRangePicker extends StatefulWidget {
  /// Called with the chosen range. Without it the demo shows a SnackBar.
  /// 'Apply Range' stays disabled until both dates are set.
  final ValueChanged<DateTimeRange>? onApply;

  const DateRangePicker({super.key, this.onApply});

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  DateTime? _start;
  DateTime? _end;

  String _format(DateTime d) => '${d.month}/${d.day}/${d.year}';

  void _apply() {
    final range = DateTimeRange(start: _start!, end: _end!);
    final onApply = widget.onApply;
    if (onApply != null) {
      onApply(range);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Selected ${_format(range.start)} to ${_format(range.end)}'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Dates')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _start != null ? _format(_start!) : 'Start date',
                      ),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _start ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (d == null || !mounted) return;
                        setState(() {
                          _start = d;
                          // A later start invalidates the end, so ask again.
                          if (_end != null && _end!.isBefore(d)) _end = null;
                        });
                      },
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward),
                ),
                Expanded(
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _end != null
                            ? '${_end!.month}/${_end!.day}/${_end!.year}'
                            : 'End date',
                      ),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _end ?? _start ?? DateTime.now(),
                          firstDate: _start ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (d == null || !mounted) return;
                        setState(() => _end = d);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _start != null && _end != null ? _apply : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Apply Range'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
