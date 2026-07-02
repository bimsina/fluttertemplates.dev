import 'package:flutter/material.dart';

class _Device {
  final IconData icon;
  final String name;
  final String room;
  bool on;
  _Device(this.icon, this.name, this.room, this.on);
}

class SmartHome extends StatefulWidget {
  const SmartHome({super.key});

  @override
  State<SmartHome> createState() => _SmartHomeState();
}

class _SmartHomeState extends State<SmartHome> {
  final _devices = [
    _Device(Icons.lightbulb_outline, 'Ceiling light', 'Living room', true),
    _Device(Icons.tv, 'Smart TV', 'Living room', false),
    _Device(Icons.thermostat, 'Thermostat', 'Hallway', true),
    _Device(Icons.speaker, 'Speaker', 'Kitchen', false),
    _Device(Icons.ac_unit, 'AC unit', 'Bedroom', true),
    _Device(Icons.door_front_door_outlined, 'Front door', 'Entry', false),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final activeCount = _devices.where((d) => d.on).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Good evening, Alex',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text('$activeCount devices active · 21°C',
              style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final s in const ['All', 'Living room', 'Kitchen', 'Bedroom'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(label: Text(s)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              for (var i = 0; i < _devices.length; i++)
                _DeviceCard(
                  device: _devices[i],
                  onToggle: () =>
                      setState(() => _devices[i].on = !_devices[i].on),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final _Device device;
  final VoidCallback onToggle;
  const _DeviceCard({required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final on = device.on;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: on ? scheme.primary : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(device.icon,
                  color: on ? scheme.onPrimary : scheme.onSurfaceVariant),
              const Spacer(),
              Switch(value: on, onChanged: (_) => onToggle()),
            ],
          ),
          const Spacer(),
          Text(device.name,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: on ? scheme.onPrimary : scheme.onSurface)),
          Text(device.room,
              style: TextStyle(
                  fontSize: 12,
                  color: on
                      ? scheme.onPrimary.withValues(alpha: 0.8)
                      : scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
