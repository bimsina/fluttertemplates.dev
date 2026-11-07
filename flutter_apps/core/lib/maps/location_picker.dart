import 'package:flutter/material.dart';

/// The place passed to [LocationPicker.onLocationSelected].
class PickedLocation {
  final String address;
  final String area;
  final double latitude;
  final double longitude;

  const PickedLocation({
    required this.address,
    required this.area,
    required this.latitude,
    required this.longitude,
  });
}

const _sampleLocations = [
  PickedLocation(
    address: '221B Baker Street',
    area: 'Marylebone, London NW1',
    latitude: 51.5238,
    longitude: -0.1586,
  ),
  PickedLocation(
    address: 'Great Russell Street',
    area: 'Bloomsbury, London WC1',
    latitude: 51.5194,
    longitude: -0.1270,
  ),
  PickedLocation(
    address: 'South Bank',
    area: 'Lambeth, London SE1',
    latitude: 51.5055,
    longitude: -0.1160,
  ),
];

class LocationPicker extends StatefulWidget {
  /// Called with the chosen place when it's confirmed. Without it the demo
  /// shows a SnackBar.
  final ValueChanged<PickedLocation>? onLocationSelected;

  const LocationPicker({super.key, this.onLocationSelected});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  PickedLocation _location = _sampleLocations.first;

  Future<void> _change() async {
    final location = await showDialog<PickedLocation>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose location'),
        children: [
          for (final option in _sampleLocations)
            ListTile(
              title: Text(option.address),
              subtitle: Text(option.area),
              trailing: option == _location ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, option),
            ),
        ],
      ),
    );
    if (location != null && mounted) setState(() => _location = location);
  }

  void _confirm() {
    final onLocationSelected = widget.onLocationSelected;
    if (onLocationSelected != null) {
      onLocationSelected(_location);
    } else {
      _showDemo(context, 'Confirmed ${_location.address} (demo)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose location')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _GridPainter(scheme)),
                ),
                // Center pin (floats slightly above center)
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Icon(Icons.location_on,
                      size: 48, color: scheme.primary),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.place_outlined, color: scheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_location.address,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          Text(_location.area,
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    TextButton(
                        onPressed: _change, child: const Text('Change')),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                      onPressed: _confirm,
                      child: const Text('Confirm location')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final ColorScheme scheme;
  _GridPainter(this.scheme);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size,
        Paint()..color = scheme.surfaceContainerHighest);
    final road = Paint()
      ..color = scheme.surface
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    for (var y = 60.0; y < size.height; y += 90) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 20), road);
    }
    for (var x = 50.0; x < size.width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x - 20, size.height), road);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.scheme != scheme;
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
