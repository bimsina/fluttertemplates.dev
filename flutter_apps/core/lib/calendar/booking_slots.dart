import 'package:flutter/material.dart';

const _slots = [
  '9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM', '11:00 AM',
  '11:30 AM', '2:00 PM', '2:30 PM', '3:00 PM', '3:30 PM',
];

class BookingSlots extends StatefulWidget {
  const BookingSlots({super.key});

  @override
  State<BookingSlots> createState() => _BookingSlotsState();
}

class _BookingSlotsState extends State<BookingSlots> {
  var _selectedSlot = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Slot')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'March 15, 2025',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_slots.length, (i) {
                final selected = _selectedSlot == i;
                return FilterChip(
                  label: Text(_slots[i]),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedSlot = selected ? -1 : i),
                );
              }),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _selectedSlot >= 0 ? () {} : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
